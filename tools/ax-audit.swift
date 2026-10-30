// macOS UI audit helper. Dumps text without terminal contents; acts only on an
// exact label or a path returned by a fresh dump. No third-party dependencies.
import AppKit
import ApplicationServices
import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8)); exit(1)
}
// Bound both AX work and output size. A single in-flight AX request can exceed
// the wall budget by the configured messaging timeout, but starts no new work.
func limit(_ name: String, fallback: Double, maximum: Double) -> Double {
    guard let raw = ProcessInfo.processInfo.environment[name] else { return fallback }
    guard let value = Double(raw), value.isFinite, value > 0, value <= maximum else {
        fail("\(name) must be positive and at most \(maximum)")
    }
    return value
}
let maxNodes = Int(limit("AX_AUDIT_MAX_NODES", fallback: 2000, maximum: 20000).rounded(.up))
let maxDepth = Int(limit("AX_AUDIT_MAX_DEPTH", fallback: 30, maximum: 100).rounded(.up))
let maxSeconds = limit("AX_AUDIT_MAX_SECONDS", fallback: 15, maximum: 120)
var traversalStarted: TimeInterval?
var truncationReasons = Set<String>()
func withinTimeBudget() -> Bool {
    guard let start = traversalStarted else { return true }
    if ProcessInfo.processInfo.systemUptime - start < maxSeconds { return true }
    truncationReasons.insert("timeLimit")
    return false
}
func attribute(_ element: AXUIElement, _ name: String) -> Any? {
    guard withinTimeBudget() else { return nil }
    var result: CFTypeRef?
    return AXUIElementCopyAttributeValue(element, name as CFString, &result) == .success ? result : nil
}
let args = CommandLine.arguments
if args.count < 3 { fail("usage: ax-audit <pid> dump|activate|press|cancel|increment|decrement|set|screenshot [label-or-path] [value-or-path]") }
guard let pid = Int32(args[1]), NSRunningApplication(processIdentifier: pid) != nil else { fail("No running process: \(args[1])") }
let app = AXUIElementCreateApplication(pid)
AXUIElementSetMessagingTimeout(app, 5)
var records: [[String: Any]] = []
var elements: [String: AXUIElement] = [:]
// AXUIElement is a remote identity, not the identity of its Swift wrapper.
// CFHash buckets plus CFEqual handle distinct wrappers for the same AX node.
var visited: [CFHashCode: [(AXUIElement, String)]] = [:]
var nodeCount = 0
func walk(_ element: AXUIElement, path: String, depth: Int) {
    guard withinTimeBudget() else { return }
    guard nodeCount < maxNodes else { truncationReasons.insert("nodeLimit"); return }
    guard depth < maxDepth else { truncationReasons.insert("depthLimit"); return }
    nodeCount += 1
    elements[path] = element
    let hash = CFHash(element)
    if let prior = visited[hash]?.first(where: { CFEqual($0.0, element) }) {
        records.append(["path": path, "role": "AXDuplicate", "duplicateOf": prior.1])
        return
    }
    visited[hash, default: []].append((element, path))
    let role = attribute(element, kAXRoleAttribute) as? String ?? ""
    var record: [String: Any] = ["path": path, "role": role]
    let desc = attribute(element, kAXDescriptionAttribute) as? String ?? ""
    let isTerminal = role == "AXTextArea" && ["终端", "Terminal"].contains(desc)
    for name in [kAXTitleAttribute, kAXDescriptionAttribute, kAXHelpAttribute, kAXPlaceholderValueAttribute, kAXIdentifierAttribute, kAXValueAttribute] {
        if name == kAXValueAttribute && isTerminal { record[name] = "<terminal content omitted>"; continue }
        let value = attribute(element, name)
        if let value = value as? String, !value.isEmpty { record[name] = value }
        else if let value = value as? NSNumber {
            if value.doubleValue.isFinite { record[name] = value }
            else { record[name + "NonFinite"] = true }
        }
    }
    if let enabled = attribute(element, kAXEnabledAttribute) as? Bool { record["enabled"] = enabled }
    if let value = attribute(element, kAXPositionAttribute), CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() {
        var p = CGPoint.zero
        if AXValueGetValue(value as! AXValue, .cgPoint, &p) {
            if p.x.isFinite && p.y.isFinite { record["position"] = [p.x, p.y] }
            else { record["invalidPosition"] = true }
        }
    }
    if let value = attribute(element, kAXSizeAttribute), CFGetTypeID(value as CFTypeRef) == AXValueGetTypeID() {
        var size = CGSize.zero
        if AXValueGetValue(value as! AXValue, .cgSize, &size) {
            if size.width.isFinite && size.height.isFinite { record["size"] = [size.width, size.height] }
            else { record["invalidSize"] = true }
        }
    }
    records.append(record)
    if let children = attribute(element, kAXChildrenAttribute) as? [AXUIElement] {
        for (index, child) in children.enumerated() {
            guard withinTimeBudget() else { break }
            guard nodeCount < maxNodes else { truncationReasons.insert("nodeLimit"); break }
            walk(child, path: "\(path)/\(index)", depth: depth + 1)
        }
    }
}
// Activation and window-ID screenshots do not need any accessibility tree.
// Previously both paid for an unbounded app-wide walk before dispatch.
switch args[2] {
case "activate", "screenshot": break
case "dump", "press", "cancel", "increment", "decrement", "set":
    traversalStarted = ProcessInfo.processInfo.systemUptime
    walk(app, path: "app", depth: 0)
    if !truncationReasons.isEmpty {
        records.append(["path": "audit", "role": "AXAuditStatus", "truncated": true,
                        "truncationReasons": truncationReasons.sorted(), "visitedNodes": nodeCount,
                        "maxNodes": maxNodes, "maxDepth": maxDepth, "maxSeconds": maxSeconds,
                        "elapsedSeconds": ProcessInfo.processInfo.systemUptime - traversalStarted!])
        FileHandle.standardError.write(Data(("AX traversal truncated: " + truncationReasons.sorted().joined(separator: ", ") + "\n").utf8))
    }
    traversalStarted = nil
default: fail("Unknown command: \(args[2])")
}
func emit(_ value: Any) {
    let data = try! JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed])
    FileHandle.standardOutput.write(data); print("")
}
switch args[2] {
case "dump": emit(records)
case "activate":
    if NSRunningApplication(processIdentifier: pid)?.activate(options: []) != true {
        // LaunchServices can reject activation of an exec-based launcher even
        // while its AX server remains available. This is one direct request,
        // never a reason to enumerate the app's descendants.
        guard AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue) == .success else {
            fail("Could not activate app through NSRunningApplication or AXFrontmost")
        }
    }
    emit(["result": "activated", "pid": pid])
case "press", "cancel", "increment", "decrement", "set":
    guard args.count >= 4 else { fail("Missing exact label or node path") }
    let query = args[3]
    // An incomplete search cannot establish that a textual label is unique.
    // A concrete, visited dump path still resolves to exactly one AX object.
    if !truncationReasons.isEmpty && elements[query] == nil {
        emit(records)
        fail("Cannot establish a unique label in a truncated traversal; use a visited node path or raise the explicit AX_AUDIT limits")
    }
    let matches = records.enumerated().filter { _, record in
        (record["path"] as? String == query) || [kAXTitleAttribute, kAXDescriptionAttribute].contains { record[$0] as? String == query }
    }
    // Duplicate title/description in a label and a button is ambiguous: require a path.
    guard matches.count == 1, let match = matches.first else { emit(matches.map { $0.element }); fail("Expected one match, found \(matches.count)") }
    guard let target = elements[match.element["path"] as? String ?? ""] else { fail("No AX object for matched node") }
    let error: AXError
    if args[2] == "press" { error = AXUIElementPerformAction(target, kAXPressAction as CFString) }
    else if args[2] == "cancel" {
        var actions: CFArray?
        guard AXUIElementCopyActionNames(target, &actions) == .success,
              (actions as? [String] ?? []).contains(kAXCancelAction) else { fail("Node does not support AXCancel") }
        error = AXUIElementPerformAction(target, kAXCancelAction as CFString)
    }
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
