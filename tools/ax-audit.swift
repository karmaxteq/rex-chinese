// macOS UI audit helper. Dumps text without terminal contents; acts only on an
// exact label or a path returned by a fresh dump. No third-party dependencies.
import AppKit
import ApplicationServices
import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8)); exit(1)
}
func attribute(_ element: AXUIElement, _ name: String) -> Any? {
    var result: CFTypeRef?
    return AXUIElementCopyAttributeValue(element, name as CFString, &result) == .success ? result : nil
}
let args = CommandLine.arguments
if args.count < 3 { fail("usage: ax-audit <pid> dump|activate|press|increment|decrement|set|screenshot [label-or-path] [value-or-path]") }
guard let pid = Int32(args[1]), NSRunningApplication(processIdentifier: pid) != nil else { fail("No running process: \(args[1])") }
let app = AXUIElementCreateApplication(pid)
AXUIElementSetMessagingTimeout(app, 5)
var records: [[String: Any]] = []
var elements: [(String, AXUIElement)] = []
func walk(_ element: AXUIElement, path: String, depth: Int) {
    guard depth < 30 else { return }
    let role = attribute(element, kAXRoleAttribute) as? String ?? ""
    var record: [String: Any] = ["path": path, "role": role]
    let desc = attribute(element, kAXDescriptionAttribute) as? String ?? ""
    let isTerminal = role == "AXTextArea" && ["终端", "Terminal"].contains(desc)
    for name in [kAXTitleAttribute, kAXDescriptionAttribute, kAXHelpAttribute, kAXPlaceholderValueAttribute, kAXIdentifierAttribute, kAXValueAttribute] {
        if name == kAXValueAttribute && isTerminal { record[name] = "<terminal content omitted>"; continue }
        if let value = attribute(element, name) as? String, !value.isEmpty { record[name] = value }
        else if let value = attribute(element, name) as? NSNumber { record[name] = value }
    }
    if let enabled = attribute(element, kAXEnabledAttribute) as? Bool { record["enabled"] = enabled }
    if let value = attribute(element, kAXPositionAttribute), CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() {
        var p = CGPoint.zero
        if AXValueGetValue(value as! AXValue, .cgPoint, &p) { record["position"] = [p.x, p.y] }
    }
    if let value = attribute(element, kAXSizeAttribute), CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() {
        var size = CGSize.zero
        if AXValueGetValue(value as! AXValue, .cgSize, &size) { record["size"] = [size.width, size.height] }
    }
    records.append(record); elements.append((path, element))
    if let children = attribute(element, kAXChildrenAttribute) as? [AXUIElement] {
        for (index, child) in children.enumerated() { walk(child, path: "\(path)/\(index)", depth: depth + 1) }
    }
}
walk(app, path: "app", depth: 0)
func emit(_ value: Any) {
    let data = try! JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed])
    FileHandle.standardOutput.write(data); print("")
}
switch args[2] {
case "dump": emit(records)
case "activate":
    guard NSRunningApplication(processIdentifier: pid)?.activate(options: []) == true else { fail("Could not activate app") }
    emit(["result": "activated", "pid": pid])
case "press", "increment", "decrement", "set":
    guard args.count >= 4 else { fail("Missing exact label or node path") }
    let query = args[3]
    let matches = records.enumerated().filter { _, record in
        (record["path"] as? String == query) || [kAXTitleAttribute, kAXDescriptionAttribute].contains { record[$0] as? String == query }
    }
    // Duplicate title/description in a label and a button is ambiguous: require a path.
    guard matches.count == 1, let match = matches.first else { emit(matches.map { $0.element }); fail("Expected one match, found \(matches.count)") }
    let target = elements[match.offset].1
    let error: AXError
    if args[2] == "press" { error = AXUIElementPerformAction(target, kAXPressAction as CFString) }
    else if args[2] == "increment" || args[2] == "decrement" {
        guard match.element["role"] as? String == "AXIncrementor" else { fail("Increment/decrement require an AXIncrementor") }
        error = AXUIElementPerformAction(target, (args[2] == "increment" ? kAXIncrementAction : kAXDecrementAction) as CFString)
    }
    else {
        guard args.count == 5 else { fail("Missing value") }
        let value: CFTypeRef
        if match.element["AXValue"] is NSNumber, let numeric = Double(args[4]) { value = NSNumber(value: numeric) }
        else { value = args[4] as CFString }
        error = AXUIElementSetAttributeValue(target, kAXValueAttribute as CFString, value)
    }
    guard error == .success else { fail("AX action reported \(error.rawValue); inspect a fresh dump before retrying, since the UI may already have changed.") }
    emit(["result": "ok", "node": match.element])
case "screenshot":
    guard args.count == 5 else { fail("screenshot requires exact window title and destination PNG") }
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    let windows = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
    let selected = windows.filter { ($0[kCGWindowOwnerPID as String] as? Int32) == pid && ($0[kCGWindowName as String] as? String ?? "") == args[3] }
    guard selected.count == 1, let number = selected.first?[kCGWindowNumber as String] as? Int else { fail("Expected one visible window named \(args[3]), found \(selected.count)") }
    let process = Process(); process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    process.arguments = ["-x", "-o", "-l", String(number), args[4]]
    try process.run(); process.waitUntilExit()
    guard process.terminationStatus == 0 else { fail("screencapture failed") }
    emit(["path": args[4], "window": number, "pid": pid])
default: fail("Unknown command: \(args[2])")
}
