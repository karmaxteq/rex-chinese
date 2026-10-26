#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static NSString *RXTranslate(NSString *s) {
    if (![s isKindOfClass:[NSString class]] || s.length == 0) return s;
    static NSDictionary *map;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        map = @{
            @"Change Session": @"切换会话",
            @"Command Palette": @"命令面板",
            @"Activity": @"活动",
            @"New Tab": @"新建标签页",
            @"Split Right": @"向右分栏",
            @"Split Down": @"向下分栏",
            @"Zoom Pane": @"缩放窗格",
            @"Close Pane": @"关闭窗格",
            @"Search Settings": @"搜索设置",
            @"Developer Mode": @"开发者模式",
            @"Sign in to Tailscale": @"登录 Tailscale",
            @"Client Info": @"客户端信息",
            @"Label": @"标签",
            @"Terminal": @"终端",
            @"Server details": @"服务器详情",
            @"Running": @"运行中",
            @"Stop Server…": @"停止服务器…",
            @"Settings": @"设置",
            @"Server": @"服务器",
            @"Interface": @"界面",
            @"Themes": @"主题",
            @"Shortcuts": @"快捷键",
            @"Integrations": @"集成",
            @"Notifications": @"通知",
            @"Remote Hosts": @"远程主机",
            @"Developer": @"开发者",
            @"Appearance": @"外观",
            @"Color scheme": @"配色方案",
            @"Light": @"浅色",
            @"Dark": @"深色",
            @"Auto": @"自动",
            @"Create Session": @"创建会话",
            @"No Sessions": @"没有会话",
            @"Add Remote Host…": @"添加远程主机…",
            @"New Tab in Session": @"会话中新建标签页",
            @"Move Pane to New Tab": @"将窗格移到新标签页",
            @"Change Session (⌘K)": @"切换会话 (⌘K)",
            @"Command Palette (⇧⌘P)": @"命令面板 (⇧⌘P)",
            @"Show Activity (⌘.)": @"显示活动 (⌘.)",
            @"New Tab (⌘T)": @"新建标签页 (⌘T)",
            @"Split layout": @"分栏布局",
            @"Move Pane": @"移动窗格",
            @"Close Tab": @"关闭标签页",
            @"Clear Filter": @"清除筛选",
            @"Filter Hosts": @"筛选主机",
            @"Hide Sidebar": @"隐藏侧边栏",
            @"More": @"更多",
            @"New Session": @"新建会话",
            @"Add": @"添加",
            @"Rename Session…": @"重命名会话…",
            @"Close Session": @"关闭会话",
            @"Customize View": @"自定义视图",
            @"Change Theme…": @"更改主题…",
            @"Interface Style": @"界面样式",
            @"Tab Buttons": @"标签页按钮",
            @"Pane Buttons": @"窗格按钮",
            @"About Rex Beta": @"关于Rex Beta",
            @"Check for Updates...": @"检查更新…",
            @"Check for Updates…": @"检查更新…",
            @"Settings…": @"设置…",
            @"Services": @"服务",
            @"Services Settings…": @"服务设置…",
            @"Services Settings\\U2026": @"服务设置…",
            @"No Services Apply": @"没有可用服务",
            @"Hide Rex Beta": @"隐藏Rex Beta",
            @"Hide Others": @"隐藏其他",
            @"Show All": @"显示全部",
            @"Quit Rex Beta": @"退出Rex Beta",
            @"Quit and Keep Windows": @"退出并保留窗口",
            @"Back": @"返回",
            @"Forward": @"前进",
            @"Go to the previous Settings page": @"转到上一个设置页面",
            @"Go to the next Settings page": @"转到下一个设置页面",
            @"Settings page": @"设置页面",
            @"Show up to five pane icons in horizontal tabs.": @"在横向标签页中最多显示五个窗格图标。",
            @"Pane headers are always shown when the vertical sidebar is hidden or positioned on the right.": @"隐藏垂直侧边栏或将其置于右侧时始终显示窗格标题。",
            @"Colors a pane and its header with the background a full-screen program such as an editor paints. Works when the terminal padding color extends.": @"使用全屏程序（例如编辑器）绘制的背景为窗格及其标题着色。终端内边距颜色扩展时生效。",
            @"Uses inactive-window styles while respecting the Fade inactive panes choice. When off, that choice applies to every pane in an inactive window.": @"使用非活动窗口样式，同时遵循“淡化非活动窗格”选项。关闭后，该选项会应用于非活动窗口中的所有窗格。",
            @"Draws a border in the accent color around the focused pane. It follows focus between panes.": @"在聚焦窗格周围绘制强调色边框，并随焦点在窗格间移动。",
            @"Evenly resizes a tab's panes whenever a pane is created or closed.": @"创建或关闭窗格时均匀调整标签页窗格大小。",
            @"Focuses a pane when you move the pointer over it, without clicking.": @"将指针移到窗格上即可聚焦，无需点击。",
            @"Client label": @"客户端标签",
            @"Remote Control": @"远程控制",
            @"Let Rex and other clients perform actions in this app.": @"允许 Rex 和其他客户端在此应用中执行操作。",
            @"Access Rex securely from your other devices.": @"从其他设备安全访问 Rex。",
            @"Rex Server Running": @"Rex 服务器运行中",
            @"Interface style": @"界面样式",
            @"Glass": @"玻璃",
            @"Classic": @"经典",
            @"Tint with theme": @"使用主题着色",
            @"Tab style": @"标签页样式",
            @"Above": @"上方",
            @"Left Side": @"左侧",
            @"Right Side": @"右侧",
            @"Use color for tab icons": @"为标签页图标使用颜色",
            @"Always": @"始终",
            @"Default": @"默认",
            @"Regular": @"常规",
            @"Block": @"块状",
            @"Normal": @"正常",
            @"Automatic (by keyboard layout)": @"自动（根据键盘布局）",
            @"Extend": @"扩展",
            @"Theme": @"主题",
            @"Ask First": @"先询问",
            @"Default login shell": @"默认登录 Shell",
            @"App icon": @"应用图标",
            @"Show app icon": @"显示应用图标",
            @"Dock and menu bar": @"程序坞和菜单栏",
            @"Pane style": @"窗格样式",
            @"Comfortable": @"舒适",
            @"Compact": @"紧凑",
            @"Typography": @"字体排印",
            @"Typography preview: regular, bold, and italic terminal text.": @"字体预览：终端普通、粗体和斜体文本。",
            @"Terminal font": @"终端字体",
            @"Font size": @"字体大小",
            @"Style": @"样式",
            @"Font smoothing": @"字体平滑",
            @"Ligatures": @"连字",
            @"Line height": @"行高",
            @"Fallback fonts": @"备用字体",
            @"Used in order for characters the terminal font doesn't have.": @"按顺序用于终端字体不包含的字符。",
            @"Add...": @"添加…",
            @"Colors": @"颜色",
            @"Adjust unreadable text against its background.": @"根据背景调整难以阅读的文本。",
            @"Improve text contrast": @"提高文本对比度",
            @"Included automatically when Force theme palette for text is enabled.": @"启用“强制使用主题文本配色”后自动包含。",
            @"Map text colors to the nearest theme color.": @"将文本颜色映射到最接近的主题颜色。",
            @"Force theme palette for text": @"强制使用主题文本配色",
            @"Read theme and program colors as wide-gamut Display P3.": @"将主题和程序颜色读取为广色域 Display P3。",
            @"Use Display P3 color space": @"使用 Display P3 色彩空间",
            @"Cursor": @"光标",
            @"Cursor preview: the selected cursor at a terminal prompt.": @"光标预览：终端提示符处的选定光标。",
            @"Cursor style": @"光标样式",
            @"Blink speed": @"闪烁速度",
            @"Blink interval": @"闪烁间隔",
            @"Ignore application requests to change cursor shape.": @"忽略应用更改光标形状的请求。",
            @"Force style": @"强制样式",
            @"Keyboard": @"键盘",
            @"Show key sequence hints": @"显示按键序列提示",
            @"Option key": @"Option 键",
            @"Automatic sends Alt on U.S. layouts and types special keys elsewhere. Applies to all terminals on this Mac, including remote hosts.": @"在美国键盘布局上自动发送 Alt，在其他布局上输入特殊按键。适用于此 Mac 上的所有终端，包括远程主机。",
            @"Padding": @"内边距",
            @"Padding color": @"内边距颜色",
            @"Background uses the pane background. Extend carries edge-cell backgrounds into the padding when appropriate. Extend Always extends them without those checks.": @"背景使用窗格背景。适用时，“扩展”会将边缘单元格背景延伸到内边距；“始终扩展”会跳过这些检查。",
            @"Selection": @"选择",
            @"Selection preview: highlighted terminal text.": @"选择预览：高亮的终端文本。",
            @"Copy on selection": @"选择后复制",
            @"Play animation on copy": @"复制时播放动画",
            @"Foreground": @"前景",
            @"Background": @"背景",
            @"Rounded corners": @"圆角",
            @"Links": @"链接",
            @"Links that open apps": @"打开应用的链接",
            @"Web, mail, and file links open directly. Other links, such as ssh://, launch the app registered for them, and any program in a terminal can print one.": @"网页、邮件和文件链接会直接打开。其他链接（例如 ssh://）会启动为其注册的应用，终端中的程序也可以输出此类链接。",
            @"Integrated Path Browser": @"集成路径浏览器",
            @"Show recently used paths": @"显示最近使用的路径",
            @"Insert Path types the path of a file or folder at the cursor. Recently used paths are shared by every session on the same host.": @"“插入路径”会在光标处输入文件或文件夹路径。同一主机上的所有会话共享最近使用的路径。",
            @"Titles": @"标题",
            @"Prefer generated titles": @"优先使用生成的标题",
            @"Show the running program and its directory instead of titles that shells set. Titles that programs set for themselves, and names you give tabs, still appear.": @"显示正在运行的程序及其目录，而不是 Shell 设置的标题。程序自行设置的标题以及你为标签页指定的名称仍会显示。",
            @"Shell": @"Shell",
            @"Startup command": @"启动命令",
            @"Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal’s working directory when available. Otherwise, they use the server’s default directory.": @"可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
            @"Filter Shortcuts": @"筛选快捷键",
            @"Filter Shortcuts…": @"筛选快捷键…",
            @"A shortcut recorded here takes priority over file-based configuration. Search for a key, such as cmd+k, to see everything bound to it. The first result is the one the key performs.": @"此处记录的快捷键优先于文件配置。搜索 cmd+k 等按键即可查看所有绑定项；第一个结果就是该按键执行的操作。",
            @"Window": @"窗口",
            @"New Window": @"新建窗口",
            @"Close Window": @"关闭窗口",
            @"Toggle Full Screen": @"切换全屏",
            @"Close": @"关闭",
            @"App": @"应用",
            @"Command Palette…": @"命令面板…",
            @"Rex Diagnostics": @"Rex 诊断",
            @"Open Onboarding Session…": @"打开入门会话…",
            @"Grant System Permissions…": @"授予系统权限…",
            @"Copy Version Info": @"复制版本信息",
            @"Copy Debug Info": @"复制调试信息",
            @"Pair Device with QR Code…": @"使用二维码配对设备…",
            @"Install Update": @"安装更新",
            @"Dismiss Notice": @"关闭通知",
            @"Dismiss notice": @"关闭通知",
            @"Dismiss notice (⇧⌘.)": @"关闭通知 (⇧⌘.)",
            @"Rex Beta is up to date": @"Rex Beta 已是最新版本",
            @"Change Shortcut…": @"更改快捷键…",
            @"Install Rex for Agents": @"为智能体安装 Rex",
            @"Restart Server…": @"重启服务器…",
            @"Session": @"会话",
            @"Change Session…": @"切换会话…",
            @"Configuration": @"配置",
            @"Copy the configuration file’s path, copy the shortcuts recorded here as Lua, or reset them all.": @"复制配置文件路径、将此处记录的快捷键复制为 Lua，或全部重置。",
            @"Coding Agents": @"编码智能体",
            @"Integrate with available agents": @"与可用智能体集成",
            @"Installs a Rex skill and session hooks for supported agents": @"为受支持的智能体安装 Rex 技能和会话钩子",
            @"Teach Claude Code, Codex, OpenCode and Pi how to use Rex.": @"教会 Claude Code、Codex、OpenCode 和 Pi 使用 Rex。",
            @"In-App Notifications": @"应用内通知",
            @"Notification position": @"通知位置",
            @"Displayed bottom right": @"显示在右下角",
            @"Top left": @"左上",
            @"Top center": @"顶部居中",
            @"Top right": @"右上",
            @"Bottom left": @"左下",
            @"Bottom center": @"底部居中",
            @"Bottom right": @"右下",
            @"Program Activity": @"程序活动",
            @"How status from processes and agents is handled": @"进程和智能体状态的处理方式",
            @"Show activity in tabs": @"在标签页中显示活动",
            @"Show system notifications": @"显示系统通知",
            @"Badge Dock icon": @"在程序坞图标上显示标记",
            @"Play sounds": @"播放声音",
            @"Include idle processes in activity": @"在活动中包含空闲进程",
            @"Show each process in tabs": @"在标签页中显示每个进程",
            @"System Notifications": @"系统通知",
            @"Terminal notifications": @"终端通知",
            @"Programs can send notifications with OSC 9 or OSC 777": @"程序可以通过 OSC 9 或 OSC 777 发送通知",
            @"Tailscale sign-in": @"Tailscale 登录",
            @"Tailscale device approval": @"Tailscale 设备批准",
            @"Tailscale failures": @"Tailscale 故障",
            @"Working、标签页、通知、Dock Badge和Sound": @"运行中、标签页、通知、程序坞标记和声音",
            @"Working、标签页": @"运行中、标签页",
            @"Blocked、标签页、通知、Dock Badge和Sound": @"已阻塞、标签页、通知、程序坞标记和声音",
            @"Error、标签页、通知、Dock Badge和Sound": @"错误、标签页、通知、程序坞标记和声音",
            @"Done、标签页、通知、Dock Badge和Sound": @"已完成、标签页、通知、程序坞标记和声音",
            @"Opens Working settings": @"打开“运行中”设置",
            @"Opens Blocked settings": @"打开“已阻塞”设置",
            @"Opens Error settings": @"打开“错误”设置",
            @"Opens Done settings": @"打开“已完成”设置",
            @"on": @"开",
            @"off": @"关",
            @"Light Mode": @"浅色模式",
            @"Dark Mode": @"深色模式",
            @"— Active": @"— 当前",
            @"New Light Theme": @"新建浅色主题",
            @"New Dark Theme": @"新建深色主题",
            @"Light theme": @"浅色主题",
            @"Dark theme": @"深色主题",
            @"Built-in": @"内置",
            @"Use extended theme palette": @"使用扩展主题调色板",
            @"Import Theme": @"导入主题",
            @"Import a Ghostty or iTerm theme file": @"导入 Ghostty 或 iTerm 主题文件",
            @"Themes are matched to an appearance based on their background color.": @"主题会根据背景颜色匹配到相应外观。",
            @"Import": @"导入",
            @"Disable this option to use a standard set of extended colors.": @"关闭此选项以使用标准的扩展颜色集。",
            @"Selected": @"已选中",
            @"Not selected": @"未选中",
            @"Duplicate Theme": @"复制主题",
            @"Scroll Left": @"向左滚动",
            @"Scroll Right": @"向右滚动",
            @"Scroll Up": @"向上滚动",
            @"Scroll Down": @"向下滚动",
            @"Command Palette Search": @"命令面板搜索",
        };
    });
    NSString *exact = map[s];
    if (exact) return exact;
    NSString *original = s;
    if ([s containsString:@"Light Mode"]) s = [s stringByReplacingOccurrencesOfString:@"Light Mode" withString:@"浅色模式"];
    if ([s containsString:@"Dark Mode"]) s = [s stringByReplacingOccurrencesOfString:@"Dark Mode" withString:@"深色模式"];
    if ([s containsString:@"— Active"]) s = [s stringByReplacingOccurrencesOfString:@"— Active" withString:@"— 当前"];
    if ([s containsString:@"Import a Ghostty or iTerm theme file"]) s = [s stringByReplacingOccurrencesOfString:@"Import a Ghostty or iTerm theme file" withString:@"导入 Ghostty 或 iTerm 主题文件"];
    if ([s containsString:@"Themes are matched to an appearance based on their background color."]) s = [s stringByReplacingOccurrencesOfString:@"Themes are matched to an appearance based on their background color." withString:@"主题会根据背景颜色匹配到相应外观。"];
    if (![s isEqualToString:original]) return s;
    if ([s hasPrefix:@"Check for Updates"]) return @"检查更新…";
    if ([s hasSuffix:@"、Running"]) return [NSString stringWithFormat:@"%@、运行中", [s substringToIndex:s.length - 8]];
    if ([s hasPrefix:@"Settings - "]) {
        return [NSString stringWithFormat:@"设置 - %@", RXTranslate([s substringFromIndex:11])];
    }
    if ([s hasPrefix:@"Rex Server Running for "]) {
        return [NSString stringWithFormat:@"Rex 服务器已运行 %@", [s substringFromIndex:23]];
    }
    NSRange serverMarker = [s rangeOfString:@"Rex Server Running for"];
    if (serverMarker.location != NSNotFound) {
        NSString *duration = [s substringFromIndex:serverMarker.location + serverMarker.length];
        return [NSString stringWithFormat:@"Rex 服务器已运行%@", duration];
    }
    if ([s hasPrefix:@"Change the shortcut for "]) {
        return [NSString stringWithFormat:@"修改 %@ 的快捷键", RXTranslate([s substringFromIndex:24])];
    }
    if ([s hasPrefix:@"Record a shortcut for "]) {
        return [NSString stringWithFormat:@"录制 %@ 的快捷键", RXTranslate([s substringFromIndex:22])];
    }
    if ([s hasPrefix:@"Click to record a different shortcut."]) {
        return @"点击以录制其他快捷键。";
    }
    if ([s hasPrefix:@"Click to record a shortcut."]) {
        return @"点击以录制快捷键。";
    }
    if ([s hasPrefix:@"Move "] && [s hasSuffix:@" pane"]) {
        NSString *middle = [s substringWithRange:NSMakeRange(5, s.length - 10)];
        return [NSString stringWithFormat:@"移动 %@ 窗格", middle];
    }
    return s;
}

static IMP origTitle, origButtonTitleGetter, origMenuTitle, origMenuTitleGetter, origMenuAttributedTitle, origMenuAttributedTitleGetter, origMenuAccessibilityValue, origMenuAccessibilityTitle, origMenuAccessibilityDescription, origWindowTitle, origStringValue, origPlaceholder, origPlaceholderGetter, origAccessibilityLabel, origAccessibilityTitle, origAccessibilityHelp, origToolTip, origAccessibilityValue, origSegmentAccessibilityValue, origSegmentAccessibilityDescription, origPopupTitleOfSelectedItem, origPopupCellTitle, origViewAccessibilityLabelGetter, origViewAccessibilityTitleGetter, origViewAccessibilityHelpGetter, origViewAccessibilityValueGetter, origViewAccessibilityValueDescriptionGetter, origViewAccessibilityRoleDescriptionGetter, origButtonAccessibilityLabel, origButtonAccessibilityTitle, origButtonAccessibilityHelp, origBundleLocalized, origSplitChildren, origSplitters, origCellStringValue, origCellSetStringValue, origCellAccessibilityLabel, origCellAccessibilityTitle, origCellAccessibilityHelp, origCellAccessibilityValue, origSwiftLabel, origSwiftHelp, origSwiftAttribute, origSwiftValue, origSwiftValueDescription, origSwiftRoleDescription, origSwiftAttributedLabel;
static void RXSetTitle(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origTitle)(self, _cmd, RXTranslate(value));
}
static NSString *RXButtonTitle(id self, SEL _cmd) {
    NSString *value = origButtonTitleGetter ? ((NSString *(*)(id, SEL))origButtonTitleGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetMenuTitle(id self, SEL _cmd, NSString *value) {
    if (origMenuTitle) ((void (*)(id, SEL, NSString *))origMenuTitle)(self, _cmd, RXTranslate(value));
}
static NSString *RXMenuTitle(id self, SEL _cmd) {
    NSString *value = origMenuTitleGetter ? ((NSString *(*)(id, SEL))origMenuTitleGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetMenuAttributedTitle(id self, SEL _cmd, NSAttributedString *value) {
    if (!origMenuAttributedTitle) return;
    NSString *translated = RXTranslate(value.string);
    if (translated && ![translated isEqualToString:value.string]) {
        value = [[NSAttributedString alloc] initWithString:translated attributes:[value attributesAtIndex:0 effectiveRange:NULL]];
    }
    ((void (*)(id, SEL, NSAttributedString *))origMenuAttributedTitle)(self, _cmd, value);
}
static NSAttributedString *RXMenuAttributedTitle(id self, SEL _cmd) {
    NSAttributedString *value = origMenuAttributedTitleGetter ? ((NSAttributedString *(*)(id, SEL))origMenuAttributedTitleGetter)(self, _cmd) : nil;
    if (!value) return nil;
    NSString *translated = RXTranslate(value.string);
    return [translated isEqualToString:value.string] ? value : [[NSAttributedString alloc] initWithString:translated attributes:[value attributesAtIndex:0 effectiveRange:NULL]];
}
static id RXMenuAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    id value = origMenuAccessibilityValue ? ((id (*)(id, SEL, NSString *))origMenuAccessibilityValue)(self, _cmd, attribute) : nil;
    if ([value isKindOfClass:[NSString class]] && ([attribute isEqualToString:NSAccessibilityTitleAttribute] || [attribute isEqualToString:NSAccessibilityDescriptionAttribute] || [attribute isEqualToString:NSAccessibilityHelpAttribute] || [attribute isEqualToString:NSAccessibilityValueAttribute])) return RXTranslate(value);
    return value;
}
static NSString *RXMenuAccessibilityTitle(id self, SEL _cmd) {
    NSString *value = origMenuAccessibilityTitle ? ((NSString *(*)(id, SEL))origMenuAccessibilityTitle)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXMenuAccessibilityDescription(id self, SEL _cmd) {
    NSString *value = origMenuAccessibilityDescription ? ((NSString *(*)(id, SEL))origMenuAccessibilityDescription)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXSegmentAccessibilityDescription(id self, SEL _cmd) {
    NSString *value = origSegmentAccessibilityDescription ? ((NSString *(*)(id, SEL))origSegmentAccessibilityDescription)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXCellStringValue(id self, SEL _cmd) {
    NSString *value = origCellStringValue ? ((NSString *(*)(id, SEL))origCellStringValue)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXCellSetStringValue(id self, SEL _cmd, NSString *value) {
    if (origCellSetStringValue) ((void (*)(id, SEL, NSString *))origCellSetStringValue)(self, _cmd, RXTranslate(value));
}
static NSString *RXPopupTitleOfSelectedItem(id self, SEL _cmd) {
    NSString *value = origPopupTitleOfSelectedItem ? ((NSString *(*)(id, SEL))origPopupTitleOfSelectedItem)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXPopupCellTitle(id self, SEL _cmd) {
    NSString *value = origPopupCellTitle ? ((NSString *(*)(id, SEL))origPopupCellTitle)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetWindowTitle(id self, SEL _cmd, NSString *value) {
    if (origWindowTitle) ((void (*)(id, SEL, NSString *))origWindowTitle)(self, _cmd, RXTranslate(value));
}
static void RXSetStringValue(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origStringValue)(self, _cmd, RXTranslate(value));
}
static void RXSetPlaceholder(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origPlaceholder)(self, _cmd, RXTranslate(value));
}
static NSString *RXPlaceholder(id self, SEL _cmd) {
    NSString *value = origPlaceholderGetter ? ((NSString *(*)(id, SEL))origPlaceholderGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetAccessibilityLabel(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origAccessibilityLabel)(self, _cmd, RXTranslate(value));
}
static void RXSetAccessibilityTitle(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origAccessibilityTitle)(self, _cmd, RXTranslate(value));
}
static void RXSetAccessibilityHelp(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origAccessibilityHelp)(self, _cmd, RXTranslate(value));
}
static void RXSetToolTip(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origToolTip)(self, _cmd, RXTranslate(value));
}
static NSString *RXViewAccessibilityLabel(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityLabelGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityLabelGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXViewAccessibilityTitle(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityTitleGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityTitleGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXViewAccessibilityHelp(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityHelpGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityHelpGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static id RXViewAccessibilityValue(id self, SEL _cmd) {
    id value = origViewAccessibilityValueGetter ? ((id (*)(id, SEL))origViewAccessibilityValueGetter)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static NSString *RXViewAccessibilityValueDescription(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityValueDescriptionGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityValueDescriptionGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXViewAccessibilityRoleDescription(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityRoleDescriptionGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityRoleDescriptionGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetButtonAccessibilityLabel(id self, SEL _cmd, NSString *value) {
    if (origButtonAccessibilityLabel) ((void (*)(id, SEL, NSString *))origButtonAccessibilityLabel)(self, _cmd, RXTranslate(value));
}
static void RXSetButtonAccessibilityTitle(id self, SEL _cmd, NSString *value) {
    if (origButtonAccessibilityTitle) ((void (*)(id, SEL, NSString *))origButtonAccessibilityTitle)(self, _cmd, RXTranslate(value));
}
static void RXSetButtonAccessibilityHelp(id self, SEL _cmd, NSString *value) {
    if (origButtonAccessibilityHelp) ((void (*)(id, SEL, NSString *))origButtonAccessibilityHelp)(self, _cmd, RXTranslate(value));
}
static NSString *RXCellLabel(id self, SEL _cmd) {
    return RXTranslate(origCellAccessibilityLabel ? ((NSString *(*)(id, SEL))origCellAccessibilityLabel)(self, _cmd) : nil);
}
static NSString *RXCellTitle(id self, SEL _cmd) {
    return RXTranslate(origCellAccessibilityTitle ? ((NSString *(*)(id, SEL))origCellAccessibilityTitle)(self, _cmd) : nil);
}
static NSString *RXCellHelp(id self, SEL _cmd) {
    return RXTranslate(origCellAccessibilityHelp ? ((NSString *(*)(id, SEL))origCellAccessibilityHelp)(self, _cmd) : nil);
}
static id RXCellAttributeValue(id self, SEL _cmd, NSString *attribute) {
    id value = origCellAccessibilityValue ? ((id (*)(id, SEL, NSString *))origCellAccessibilityValue)(self, _cmd, attribute) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static NSString *RXSwiftLabel(id self, SEL _cmd) {
    return RXTranslate(origSwiftLabel ? ((NSString *(*)(id, SEL))origSwiftLabel)(self, _cmd) : nil);
}
static NSString *RXSwiftHelp(id self, SEL _cmd) {
    return RXTranslate(origSwiftHelp ? ((NSString *(*)(id, SEL))origSwiftHelp)(self, _cmd) : nil);
}
static id RXSwiftAttribute(id self, SEL _cmd, NSString *attribute) {
    id value = origSwiftAttribute ? ((id (*)(id, SEL, NSString *))origSwiftAttribute)(self, _cmd, attribute) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftValue(id self, SEL _cmd) {
    id value = origSwiftValue ? ((id (*)(id, SEL))origSwiftValue)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftValueDescription(id self, SEL _cmd) {
    id value = origSwiftValueDescription ? ((id (*)(id, SEL))origSwiftValueDescription)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftRoleDescription(id self, SEL _cmd) {
    id value = origSwiftRoleDescription ? ((id (*)(id, SEL))origSwiftRoleDescription)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static NSAttributedString *RXSwiftAttributedLabel(id self, SEL _cmd) {
    NSAttributedString *value = origSwiftAttributedLabel ? ((NSAttributedString *(*)(id, SEL))origSwiftAttributedLabel)(self, _cmd) : nil;
    return value ? [[NSAttributedString alloc] initWithString:RXTranslate(value.string)] : nil;
}
static NSArray *RXSplitChildren(id self, SEL _cmd) {
    NSArray *children = origSplitChildren ? ((NSArray *(*)(id, SEL))origSplitChildren)(self, _cmd) : @[];
    for (id child in children) {
        NSString *label = [child respondsToSelector:@selector(accessibilityLabel)] ? [child accessibilityLabel] : nil;
        NSString *title = [child respondsToSelector:@selector(accessibilityTitle)] ? [child accessibilityTitle] : nil;
        if (label.length && [child respondsToSelector:@selector(setAccessibilityLabel:)]) [child setAccessibilityLabel:RXTranslate(label)];
        if (title.length && [child respondsToSelector:@selector(setAccessibilityTitle:)]) [child setAccessibilityTitle:RXTranslate(title)];
    }
    return children;
}

static NSArray *RXSplitters(id self, SEL _cmd) {
    NSArray *children = origSplitters ? ((NSArray *(*)(id, SEL))origSplitters)(self, _cmd) : @[];
    for (id child in children) {
        NSString *label = [child respondsToSelector:@selector(accessibilityLabel)] ? [child accessibilityLabel] : nil;
        NSString *title = [child respondsToSelector:@selector(accessibilityTitle)] ? [child accessibilityTitle] : nil;
        if (label.length && [child respondsToSelector:@selector(setAccessibilityLabel:)]) [child setAccessibilityLabel:RXTranslate(label)];
        if (title.length && [child respondsToSelector:@selector(setAccessibilityTitle:)]) [child setAccessibilityTitle:RXTranslate(title)];
    }
    return children;
}

static NSString *RXBundleLocalized(id self, SEL _cmd, NSString *key, NSString *value, NSString *table) {
    NSString *result = origBundleLocalized ? ((NSString *(*)(id, SEL, NSString *, NSString *, NSString *))origBundleLocalized)(self, _cmd, key, value, table) : value;
    NSString *translated = RXTranslate(result);
    if ([translated isEqualToString:result]) translated = RXTranslate(key);
    return translated;
}
static id RXAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    id value = ((id (*)(id, SEL, NSString *))origAccessibilityValue)(self, _cmd, attribute);
    if ([value isKindOfClass:[NSString class]] && ([attribute isEqualToString:NSAccessibilityTitleAttribute] || [attribute isEqualToString:NSAccessibilityDescriptionAttribute] || [attribute isEqualToString:NSAccessibilityHelpAttribute] || [attribute isEqualToString:NSAccessibilityValueAttribute])) {
        return RXTranslate(value);
    }
    return value;
}
static IMP RXHook(Class cls, SEL sel, IMP replacement) {
    Method method = class_getInstanceMethod(cls, sel);
    if (!method) return NULL;
    IMP original = method_getImplementation(method);
    method_setImplementation(method, replacement);
    return original;
}

static void RXRefreshMenu(NSMenu *menu) {
    if (![menu isKindOfClass:[NSMenu class]]) return;
    for (NSMenuItem *item in menu.itemArray) {
        NSString *title = item.title;
        NSString *translated = RXTranslate(title);
        if (translated.length && ![translated isEqualToString:title]) [item setTitle:translated];
        NSAttributedString *attributed = item.attributedTitle;
        NSString *attributedText = RXTranslate(attributed.string);
        if (attributedText.length && ![attributedText isEqualToString:attributed.string]) {
            [item setAttributedTitle:[[NSAttributedString alloc] initWithString:attributedText attributes:[attributed attributesAtIndex:0 effectiveRange:NULL]]];
        }
        RXRefreshMenu(item.submenu);
    }
}

static void RXWalkAX(id element, NSUInteger depth);

static void RXWalk(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return;
    NSString *label = view.accessibilityLabel;
    NSString *translated = RXTranslate(label);
    if (translated != label && ![translated isEqualToString:label]) view.accessibilityLabel = translated;
    NSString *help = view.accessibilityHelp;
    NSString *translatedHelp = RXTranslate(help);
    if (translatedHelp != help && ![translatedHelp isEqualToString:help]) view.accessibilityHelp = translatedHelp;
    NSString *title = view.accessibilityTitle;
    NSString *translatedTitle = RXTranslate(title);
    if (translatedTitle != title && ![translatedTitle isEqualToString:title]) view.accessibilityTitle = translatedTitle;
    if ([view isKindOfClass:[NSControl class]]) { NSCell *cell = [(NSControl *)view cell]; if (cell) RXWalkAX(cell, 0); }
    RXWalkAX(view, 0);
    for (NSView *child in view.subviews) RXWalk(child);
}

static void RXWalkAX(id element, NSUInteger depth) {
    if (!element || depth > 20 || ![element respondsToSelector:@selector(accessibilityAttributeValue:)]) return;
    NSArray *attrs = @[NSAccessibilityDescriptionAttribute, NSAccessibilityTitleAttribute, NSAccessibilityHelpAttribute, NSAccessibilityPlaceholderValueAttribute, NSAccessibilityValueAttribute, NSAccessibilityValueDescriptionAttribute, NSAccessibilityRoleDescriptionAttribute];
    for (NSString *attribute in attrs) {
        id value = [element accessibilityAttributeValue:attribute];
        if ([value isKindOfClass:[NSString class]]) {
            NSString *translated = RXTranslate(value);
            if (![translated isEqualToString:value] && [element respondsToSelector:@selector(accessibilitySetValue:forAttribute:)]) {
                [element accessibilitySetValue:translated forAttribute:attribute];
            }
        }
    }
    id children = [element accessibilityAttributeValue:NSAccessibilityChildrenAttribute];
    if ([children isKindOfClass:[NSArray class]]) {
        for (id child in (NSArray *)children) RXWalkAX(child, depth + 1);
    }
}

static void RXRefreshAccessibility(void) {
    for (NSWindow *window in NSApp.windows) {
        RXWalk(window.contentView);
        RXWalkAX(window, 0);
    }
    RXRefreshMenu(NSApp.mainMenu);
}

__attribute__((constructor)) static void RexChineseInstall(void) {
    @autoreleasepool {
        origTitle = RXHook([NSButton class], @selector(setTitle:), (IMP)RXSetTitle);
        origButtonTitleGetter = RXHook([NSButton class], @selector(title), (IMP)RXButtonTitle);
        origMenuTitle = RXHook([NSMenuItem class], @selector(setTitle:), (IMP)RXSetMenuTitle);
        origMenuTitleGetter = RXHook([NSMenuItem class], @selector(title), (IMP)RXMenuTitle);
        origMenuAttributedTitle = RXHook([NSMenuItem class], @selector(setAttributedTitle:), (IMP)RXSetMenuAttributedTitle);
        origMenuAttributedTitleGetter = RXHook([NSMenuItem class], @selector(attributedTitle), (IMP)RXMenuAttributedTitle);
        origMenuAccessibilityValue = RXHook([NSMenuItem class], @selector(accessibilityAttributeValue:), (IMP)RXMenuAccessibilityAttributeValue);
        origMenuAccessibilityTitle = RXHook([NSMenuItem class], @selector(accessibilityTitle), (IMP)RXMenuAccessibilityTitle);
        origMenuAccessibilityDescription = RXHook([NSMenuItem class], @selector(accessibilityDescription), (IMP)RXMenuAccessibilityDescription);
        origWindowTitle = RXHook([NSWindow class], @selector(setTitle:), (IMP)RXSetWindowTitle);
        origStringValue = RXHook([NSControl class], @selector(setStringValue:), (IMP)RXSetStringValue);
        origPlaceholder = RXHook([NSTextField class], @selector(setPlaceholderString:), (IMP)RXSetPlaceholder);
        origPlaceholderGetter = RXHook([NSTextField class], @selector(placeholderString), (IMP)RXPlaceholder);
        origAccessibilityLabel = RXHook([NSView class], @selector(setAccessibilityLabel:), (IMP)RXSetAccessibilityLabel);
        origAccessibilityTitle = RXHook([NSView class], @selector(setAccessibilityTitle:), (IMP)RXSetAccessibilityTitle);
        origAccessibilityHelp = RXHook([NSView class], @selector(setAccessibilityHelp:), (IMP)RXSetAccessibilityHelp);
        origToolTip = RXHook([NSView class], @selector(setToolTip:), (IMP)RXSetToolTip);
        origViewAccessibilityLabelGetter = RXHook([NSView class], @selector(accessibilityLabel), (IMP)RXViewAccessibilityLabel);
        origViewAccessibilityTitleGetter = RXHook([NSView class], @selector(accessibilityTitle), (IMP)RXViewAccessibilityTitle);
        origViewAccessibilityHelpGetter = RXHook([NSView class], @selector(accessibilityHelp), (IMP)RXViewAccessibilityHelp);
        origViewAccessibilityValueGetter = RXHook([NSView class], @selector(accessibilityValue), (IMP)RXViewAccessibilityValue);
        origViewAccessibilityValueDescriptionGetter = RXHook([NSView class], @selector(accessibilityValueDescription), (IMP)RXViewAccessibilityValueDescription);
        origViewAccessibilityRoleDescriptionGetter = RXHook([NSView class], @selector(accessibilityRoleDescription), (IMP)RXViewAccessibilityRoleDescription);
        origAccessibilityValue = RXHook([NSView class], @selector(accessibilityAttributeValue:), (IMP)RXAccessibilityAttributeValue);
        Class segmentClass = objc_getClass("NSAccessibilitySegment");
        origSegmentAccessibilityValue = segmentClass ? RXHook(segmentClass, @selector(accessibilityAttributeValue:), (IMP)RXAccessibilityAttributeValue) : NULL;
        origSegmentAccessibilityDescription = segmentClass ? RXHook(segmentClass, @selector(accessibilityDescription), (IMP)RXSegmentAccessibilityDescription) : NULL;
        origCellStringValue = RXHook([NSCell class], @selector(stringValue), (IMP)RXCellStringValue);
        origCellSetStringValue = RXHook([NSCell class], @selector(setStringValue:), (IMP)RXCellSetStringValue);
        origPopupTitleOfSelectedItem = RXHook([NSPopUpButton class], @selector(titleOfSelectedItem), (IMP)RXPopupTitleOfSelectedItem);
        origPopupCellTitle = RXHook([NSPopUpButtonCell class], @selector(title), (IMP)RXPopupCellTitle);
        origBundleLocalized = RXHook([NSBundle class], @selector(localizedStringForKey:value:table:), (IMP)RXBundleLocalized);
        Class splitClass = objc_getClass("SuperSplit.SuperSplitLayoutAccessibilityNSView");
        origSplitChildren = splitClass ? RXHook(splitClass, @selector(accessibilityChildren), (IMP)RXSplitChildren) : NULL;
        origSplitters = splitClass ? RXHook(splitClass, @selector(accessibilitySplitters), (IMP)RXSplitters) : NULL;
        origButtonAccessibilityLabel = RXHook([NSButton class], @selector(setAccessibilityLabel:), (IMP)RXSetButtonAccessibilityLabel);
        origButtonAccessibilityTitle = RXHook([NSButton class], @selector(setAccessibilityTitle:), (IMP)RXSetButtonAccessibilityTitle);
        origButtonAccessibilityHelp = RXHook([NSButton class], @selector(setAccessibilityHelp:), (IMP)RXSetButtonAccessibilityHelp);
        origCellAccessibilityLabel = RXHook([NSCell class], @selector(accessibilityLabel), (IMP)RXCellLabel);
        origCellAccessibilityTitle = RXHook([NSCell class], @selector(accessibilityTitle), (IMP)RXCellTitle);
        origCellAccessibilityHelp = RXHook([NSCell class], @selector(accessibilityHelp), (IMP)RXCellHelp);
        origCellAccessibilityValue = RXHook([NSCell class], @selector(accessibilityAttributeValue:), (IMP)RXCellAttributeValue);
        Class swiftNode = objc_getClass("SwiftUI.AccessibilityNode");
        origSwiftLabel = swiftNode ? RXHook(swiftNode, @selector(accessibilityLabel), (IMP)RXSwiftLabel) : NULL;
        origSwiftHelp = swiftNode ? RXHook(swiftNode, @selector(accessibilityHelp), (IMP)RXSwiftHelp) : NULL;
        origSwiftAttribute = swiftNode ? RXHook(swiftNode, @selector(accessibilityAttributeValue:), (IMP)RXSwiftAttribute) : NULL;
        origSwiftValue = swiftNode ? RXHook(swiftNode, @selector(accessibilityValue), (IMP)RXSwiftValue) : NULL;
        origSwiftValueDescription = swiftNode ? RXHook(swiftNode, @selector(accessibilityValueDescription), (IMP)RXSwiftValueDescription) : NULL;
        origSwiftRoleDescription = swiftNode ? RXHook(swiftNode, @selector(accessibilityRoleDescription), (IMP)RXSwiftRoleDescription) : NULL;
        origSwiftAttributedLabel = swiftNode ? RXHook(swiftNode, @selector(accessibilityAttributedLabel), (IMP)RXSwiftAttributedLabel) : NULL;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidBeginTrackingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                RXRefreshMenu(note.object);
                RXRefreshMenu(NSApp.mainMenu);
            }];
            NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) { RXRefreshAccessibility(); }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    }
}
