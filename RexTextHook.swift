import Foundation
import SwiftUI

private let translations: [String: String] = [
  "Settings": "设置",
  "Server": "服务器",
  "Interface": "界面",
  "Themes": "主题",
  "Terminal": "终端",
  "Shortcuts": "快捷键",
  "Integrations": "集成",
  "Notifications": "通知",
  "Remote Hosts": "远程主机",
  "Developer": "开发者",
  "Running": "运行中",
  "Rex Server": "Rex 服务器",
  "Interface style": "界面样式",
  "Color scheme": "配色方案",
  "Auto": "自动",
  "Light": "浅色",
  "Dark": "深色",
  "Glass": "玻璃",
  "Classic": "经典",
  "Tint with theme": "使用主题着色",
  "Tab style": "标签页样式",
  "Above": "上方",
  "Left Side": "左侧",
  "Right Side": "右侧",
  "Use color for tab icons": "为标签页图标使用颜色",
  "Shell icon theme": "Shell 图标主题",
  "Default": "默认",
  "Window": "窗口",
  "New Window": "新建窗口",
  "Close Window": "关闭窗口",
  "Toggle Full Screen": "切换全屏",
  "Close": "关闭",
  "App": "应用",
  "Command Palette…": "命令面板…",
  "Settings…": "设置…",
  "Rex Diagnostics": "Rex 诊断",
  "Record Shortcut": "录制快捷键",
  "Typography": "字体排印",
  "Terminal font": "终端字体",
  "Font size": "字体大小",
  "Style": "样式",
  "Font smoothing": "字体平滑",
  "Ligatures": "连字",
  "Line height": "行高",
  "Fallback fonts": "备用字体",
  "Used in order for characters the terminal font doesn't have.": "按顺序用于终端字体不包含的字符。",
  "Add…": "添加…",
  "Add...": "添加…",
  "Colors": "颜色",
  "Improve text contrast": "提高文本对比度",
  "Adjust unreadable text against its background.": "根据背景调整难以阅读的文本。",
  "Force theme palette for text": "强制使用主题文本配色",
  "Cursor": "光标",
  "Keyboard": "键盘",
  "Selection": "选择",
  "Links": "链接",
  "Titles": "标题",
  "Shell": "Shell",
  "Dynamic": "动态",
  "Choose…": "选择…",
  "Choose...": "选择…",
  "Coding Agents": "编码智能体",
  "Integrate with available agents": "与可用智能体集成",
  "Installs a Rex skill and session hooks for supported agents": "为受支持的智能体安装 Rex 技能和会话钩子",
  "Teach Claude Code, Codex, OpenCode and Pi how to use Rex.": "教会 Claude Code、Codex、OpenCode 和 Pi 使用 Rex。",
  "In-App Notifications": "应用内通知",
  "Notification position": "通知位置",
  "Displayed bottom right": "显示在右下角",
  "Program Activity": "程序活动",
  "How status from processes and agents is handled": "进程和智能体状态的处理方式",
  "Show activity in tabs": "在标签页中显示活动",
  "Show system notifications": "显示系统通知",
  "Badge Dock icon": "在程序坞图标上显示标记",
  "Play sounds": "播放声音",
  "System Notifications": "系统通知",
  "Terminal notifications": "终端通知",
  "Tailscale sign-in": "Tailscale 登录",
  "Tailscale device approval": "Tailscale 设备批准",
  "Tailscale failures": "Tailscale 故障",
  "Developer Mode": "开发者模式",
  "Expose settings for development and debugging.": "显示用于开发和调试的设置。",
  "No Remote Hosts": "没有远程主机",
  "Add a Rex HTTP or HTTPS address to use its sessions in every window.": "添加 Rex HTTP 或 HTTPS 地址，以便在每个窗口中使用其会话。",
  "Sign In": "登录",
  "Sign in to Tailscale": "登录 Tailscale",
  "Access Rex securely from your other devices.": "从其他设备安全访问 Rex。",
  "Remote Control": "远程控制",
  "Let Rex and other clients perform actions in this app.": "允许 Rex 和其他客户端在此应用中执行操作。",
  "Client Info": "客户端信息",
  "Label": "标签",
  "Stop Server…": "停止服务器…",
  "Server details": "服务器详情",
  "Back": "返回",
  "Forward": "前进",
  "Filter Shortcuts…": "筛选快捷键…",
  "Filter Shortcuts...": "筛选快捷键…",
  "A shortcut recorded here takes priority over file-based configuration. Search for a key, such as cmd+k, to see everything bound to it. The first result is the one the key performs.": "此处记录的快捷键优先于文件配置。搜索 cmd+k 等按键即可查看所有绑定项；第一个结果就是该按键执行的操作。",
  "Light Mode": "浅色模式",
  "Dark Mode": "深色模式",
  "— Active": "— 当前",
  "New Light Theme": "新建浅色主题",
  "New Dark Theme": "新建深色主题",
  "Built-in": "内置",
  "Use extended theme palette": "使用扩展主题调色板",
  "Import Theme": "导入主题",
  "Import": "导入",
  "New": "新建",
  "Pane style": "窗格样式",
  "Pane Style": "窗格样式",
  "Show app icon": "显示应用图标",
  "Dock and menu bar": "程序坞和菜单栏",
  "Surface & Content": "表面与内容",
  "Always": "始终",
  "For active panes": "对活动窗格",
  "For active tabs": "对活动标签页",
  "Never": "从不",
  "Regular": "常规",
  "Block": "块状",
  "Normal": "正常",
  "Automatic (by keyboard layout)": "自动（根据键盘布局）",
  "Extend": "扩展",
  "Theme": "主题",
  "Ask First": "先询问",
  "Default login shell": "默认登录 Shell",
  "Use Display P3 color space": "使用 Display P3 色彩空间",
  "Read theme and program colors as wide-gamut Display P3.": "将主题和程序颜色读取为广色域 Display P3。",
  "Cursor style": "光标样式",
  "Blink speed": "闪烁速度",
  "Force style": "强制样式",
  "Ignore application requests to change cursor shape.": "忽略应用更改光标形状的请求。",
  "Show key sequence hints": "显示按键序列提示",
  "Option key": "Option 键",
  "Automatic sends Alt on U.S. layouts and types special keys elsewhere. Applies to all terminals on this Mac, including remote hosts.": "在美国键盘布局上自动发送 Alt，在其他布局上输入特殊按键。适用于此 Mac 上的所有终端，包括远程主机。",
  "Filter Shortcuts": "筛选快捷键",
  "Opens Running settings": "打开“运行中”设置",
  "Dock Badge and Sound": "程序坞标记和声音",
  "Dock Badge和Sound": "程序坞标记和声音",
  "Open Onboarding Session…": "打开入门会话…",
  "Open Onboarding Session...": "打开入门会话…",
  "Working": "运行中",
  "Blocked": "已阻塞",
  "Error": "错误",
  "Done": "已完成",
  "Dock Badge": "程序坞标记",
  "Sound": "声音",
  "Working、标签页": "运行中、标签页",
  "Blocked、标签页、通知、Dock Badge和Sound": "已阻塞、标签页、通知、程序坞标记和声音",
  "Error、标签页、通知、Dock Badge和Sound": "错误、标签页、通知、程序坞标记和声音",
  "Done、标签页、通知、Dock Badge和Sound": "已完成、标签页、通知、程序坞标记和声音",
  "New Session": "新建会话",
  "Add Remote Host…": "添加远程主机…",
  "Add Remote Host...": "添加远程主机…",
  "New Tab": "新建标签页",
  "Go to Directory…": "前往目录…",
  "Go to Directory...": "前往目录…",
  "Close Tab": "关闭标签页",
  "Close Session": "关闭会话",
  "Check for Updates...": "检查更新…",
  "Check for Updates…": "检查更新…",
  "Find": "查找",
  "Split Left": "向左分栏",
  "Rex Help": "Rex 帮助",
  "Merino Light": "Merino 浅色",
  "Alpine Milk": "Alpine 牛奶",
  "Buttercream Diner": "奶油餐厅",
  "Coastal Linen": "海岸亚麻",
  "Glacier Mint": "冰川薄荷",
  "Ivory Gallery": "象牙画廊",
  "Lavender Postcard": "薰衣草明信片",
  "Newsprint Fog": "报纸薄雾",
  "Orchard Breeze": "果园微风",
  "Peach Veranda": "桃色阳台",
  "Porcelain Morning": "瓷器晨曦",
  "Silver Point Light": "银点浅色",
  "Sunlit Parchment": "阳光羊皮纸",
  "Terracotta Noon": "陶土正午",
  "Merino Dark": "Merino 深色",
  "Abyssal Trench": "深渊海沟",
  "Basalt Shore": "玄武岩海岸",
  "Cathode Amber": "阴极琥珀",
  "Charcoal Atelier": "炭黑工坊",
  "Cinder Peak": "煤渣峰",
  "Cobalt Foundry": "钴蓝铸造厂",
  "Ember Hollow": "余烬谷",
  "Heliotrope Haze": "天芥菜薄雾",
  "Ink Meridian": "墨色子午线",
  "Juniper Smoke": "杜松烟",
  "Midnight Tundra": "午夜苔原",
  "Misty Forest": "迷雾森林",
  "Moss Cathedral": "苔藓大教堂",
  "Neon Arcade": "霓虹街机",
  "Nocturne Rose": "夜曲玫瑰",
  "Oxblood Library": "牛血红图书馆",
  "Petrol Lagoon": "石油蓝泻湖",
  "Phosphor Archive": "磷光档案",
  "Polar Aurora": "极地极光",
  "Roasted Umber": "烘烤赭石",
  "Saffron Nightfall": "藏红花夜幕",
  "Silver Point Dark": "银点深色",
  "Sonoran Dusk": "索诺兰暮色",
  "Velvet Dusk": "天鹅绒暮色",
  "Whitby Bay": "惠特比湾",
  "Default — Dynamic": "默认 — 动态",
  "Enter Full Screen": "进入全屏",
  "Go to Session": "前往会话",
  "Rename Session": "重命名会话",
  "Open Session on Web…": "在网页上打开会话…",
  "Open Session on Web...": "在网页上打开会话…",
  "Host": "主机",
  "Switch Host": "切换主机",
  "Remove Host…": "移除主机…",
  "Remove Host...": "移除主机…",
  "Tab": "标签页",
  "Rename Tab": "重命名标签页",
  "Go to Tab": "前往标签页",
  "Move Tab": "移动标签页",
  "Move Tab to New Window": "将标签页移到新窗口",
  "Why this shortcut can't be recorded": "为什么无法录制此快捷键",
  "Bindable only with arguments, from your configuration file": "只能从配置文件通过参数绑定。",
  "Built into Rex. A shortcut in your configuration file or one recorded here replaces it.": "Rex 内置快捷键。配置文件中的快捷键或在此处记录的快捷键会替代它。",
  "Change Session": "切换会话",
  "Command Palette": "命令面板",
  "Activity": "活动",
  "Split Right": "向右分栏",
  "Split Down": "向下分栏",
  "Zoom Pane": "缩放窗格",
  "Close Pane": "关闭窗格",
  "Search Settings": "搜索设置",
  "Appearance": "外观",
  "Create Session": "创建会话",
  "No Sessions": "没有会话",
  "New Tab in Session": "会话中新建标签页",
  "Move Pane to New Tab": "将窗格移到新标签页",
  "Change Session (⌘K)": "切换会话 (⌘K)",
  "Command Palette (⇧⌘P)": "命令面板 (⇧⌘P)",
  "Show Activity (⌘.)": "显示活动 (⌘.)",
  "New Tab (⌘T)": "新建标签页 (⌘T)",
  "Split layout": "分栏布局",
  "Move Pane": "移动窗格",
  "Clear Filter": "清除筛选",
  "Filter Hosts": "筛选主机",
  "Hide Sidebar": "隐藏侧边栏",
  "More": "更多",
  "Add": "添加",
  "Rename Session…": "重命名会话…",
  "Customize View": "自定义视图",
  "Change Theme…": "更改主题…",
  "Interface Style": "界面样式",
  "Tab Buttons": "标签页按钮",
  "Pane Buttons": "窗格按钮",
  "About Rex Beta": "关于Rex Beta",
  "About Rex Beta…": "关于Rex Beta…",
  "Services": "服务",
  "Services Settings…": "服务设置…",
  "No Services Apply": "没有可用服务",
  "Hide Rex Beta": "隐藏Rex Beta",
  "Hide Others": "隐藏其他",
  "Show All": "显示全部",
  "Quit Rex Beta": "退出Rex Beta",
  "Quit and Keep Windows": "退出并保留窗口",
  "Go to the previous Settings page": "转到上一个设置页面",
  "Go to the next Settings page": "转到下一个设置页面",
  "Settings page": "设置页面",
  "Show up to five pane icons in horizontal tabs.": "在横向标签页中最多显示五个窗格图标。",
  "Pane headers are always shown when the vertical sidebar is hidden or positioned on the right.": "隐藏垂直侧边栏或将其置于右侧时始终显示窗格标题。",
  "Colors a pane and its header with the background a full-screen program such as an editor paints. Works when the terminal padding color extends.": "使用全屏程序（例如编辑器）绘制的背景为窗格及其标题着色。终端内边距颜色扩展时生效。",
  "Uses inactive-window styles while respecting the Fade inactive panes choice. When off, that choice applies to every pane in an inactive window.": "使用非活动窗口样式，同时遵循“淡化非活动窗格”选项。关闭后，该选项会应用于非活动窗口中的所有窗格。",
  "Draws a border in the accent color around the focused pane. It follows focus between panes.": "在聚焦窗格周围绘制强调色边框，并随焦点在窗格间移动。",
  "Evenly resizes a tab's panes whenever a pane is created or closed.": "创建或关闭窗格时均匀调整标签页窗格大小。",
  "Focuses a pane when you move the pointer over it, without clicking.": "将指针移到窗格上即可聚焦，无需点击。",
  "Client label": "客户端标签",
  "Rex Server Running": "Rex 服务器运行中",
  "Tint with the theme": "使用主题着色",
  "App icon": "应用图标",
  "Comfortable": "舒适",
  "Compact": "紧凑",
  "Typography preview: regular, bold, and italic terminal text.": "字体预览：终端普通、粗体和斜体文本。",
  "Included automatically when Force theme palette for text is enabled.": "启用“强制使用主题文本配色”后自动包含。",
  "Map text colors to the nearest theme color.": "将文本颜色映射到最接近的主题颜色。",
  "Cursor preview: the selected cursor at a terminal prompt.": "光标预览：终端提示符处的选定光标。",
  "Blink interval": "闪烁间隔",
  "Padding": "内边距",
  "Padding color": "内边距颜色",
  "Background uses the pane background. Extend carries edge-cell backgrounds into the padding when appropriate. Extend Always extends them without those checks.": "背景使用窗格背景。适用时，“扩展”会将边缘单元格背景延伸到内边距；“始终扩展”会跳过这些检查。",
  "Selection preview: highlighted terminal text.": "选择预览：高亮的终端文本。",
  "Copy on selection": "选择后复制",
  "Play animation on copy": "复制时播放动画",
  "Foreground": "前景",
  "Background": "背景",
  "Rounded corners": "圆角",
  "Links that open apps": "打开应用的链接",
  "Web, mail, and file links open directly. Other links, such as ssh://, launch the app registered for them, and any program in a terminal can print one.": "网页、邮件和文件链接会直接打开。其他链接（例如 ssh://）会启动为其注册的应用，终端中的程序也可以输出此类链接。",
  "Integrated Path Browser": "集成路径浏览器",
  "Show recently used paths": "显示最近使用的路径",
  "Insert Path types the path of a file or folder at the cursor. Recently used paths are shared by every session on the same host.": "“插入路径”会在光标处输入文件或文件夹路径。同一主机上的所有会话共享最近使用的路径。",
  "Prefer generated titles": "优先使用生成的标题",
  "Show the running program and its directory instead of titles that shells set. Titles that programs set for themselves, and names you give tabs, still appear.": "显示正在运行的程序及其目录，而不是 Shell 设置的标题。程序自行设置的标题以及你为标签页指定的名称仍会显示。",
  "Startup command": "启动命令",
  "Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal’s working directory when available. Otherwise, they use the server’s default directory.": "可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
  "Grant System Permissions…": "授予系统权限…",
  "Copy Version Info": "复制版本信息",
  "Copy Debug Info": "复制调试信息",
  "Pair Device with QR Code…": "使用二维码配对设备…",
  "Install Update": "安装更新",
  "Dismiss Notice": "关闭通知",
  "Dismiss notice": "关闭通知",
  "Dismiss notice (⇧⌘.)": "关闭通知 (⇧⌘.)",
  "Rex Beta is up to date": "Rex Beta 已是最新版本",
  "Change Shortcut…": "更改快捷键…",
  "Install Rex for Agents": "为智能体安装 Rex",
  "Restart Server…": "重启服务器…",
  "Session": "会话",
  "Change Session…": "切换会话…",
  "Configuration": "配置",
  "Copy the configuration file’s path, copy the shortcuts recorded here as Lua, or reset them all.": "复制配置文件路径、将此处记录的快捷键复制为 Lua，或全部重置。",
  "Top left": "左上",
  "Top center": "顶部居中",
  "Top right": "右上",
  "Bottom left": "左下",
  "Bottom center": "底部居中",
  "Bottom right": "右下",
  "Include idle processes in activity": "在活动中包含空闲进程",
  "Show each process in tabs": "在标签页中显示每个进程",
  "Programs can send notifications with OSC 9 or OSC 777": "程序可以通过 OSC 9 或 OSC 777 发送通知",
  "Working、标签页、通知、Dock Badge和Sound": "运行中、标签页、通知、程序坞标记和声音",
  "Opens Working settings": "打开“运行中”设置",
  "Opens Blocked settings": "打开“已阻塞”设置",
  "Opens Error settings": "打开“错误”设置",
  "Opens Done settings": "打开“已完成”设置",
  "on": "开",
  "off": "关",
  "Light theme": "浅色主题",
  "Dark theme": "深色主题",
  "Import a Ghostty or iTerm theme file": "导入 Ghostty 或 iTerm 主题文件",
  "Themes are matched to an appearance based on their background color.": "主题会根据背景颜色匹配到相应外观。",
  "Disable this option to use a standard set of extended colors.": "关闭此选项以使用标准的扩展颜色集。",
  "Selected": "已选中",
  "Not selected": "未选中",
  "Duplicate Theme": "复制主题",
  "Scroll Left": "向左滚动",
  "Scroll Right": "向右滚动",
  "Scroll Up": "向上滚动",
  "Scroll Down": "向下滚动",
  "Command Palette Search": "命令面板搜索",
  "Insert Path…": "插入路径…",
  "Find…": "查找…",
  "Find Next": "查找下一个",
  "Find Previous": "查找上一个",
  "Filter Page": "筛选页面",
  "AutoFill": "自动填充",
  "Start Dictation…": "开始听写…",
  "Emoji & Symbols": "表情与符号",
  "Refresh Sessions": "刷新会话",
  "Pane": "窗格",
  "Split Up": "向上分栏",
  "Split Best Fit": "最佳分栏",
  "Focus Left": "聚焦左侧窗格",
  "Focus Right": "聚焦右侧窗格",
  "Focus Up": "聚焦上方窗格",
  "Focus Down": "聚焦下方窗格",
  "Focus Previous Pane": "聚焦上一个窗格",
  "Focus Next Pane": "聚焦下一个窗格",
  "Move Pane Left": "将窗格向左移动",
  "Move Pane Right": "将窗格向右移动",
  "Move Pane Up": "将窗格向上移动",
  "Move Pane Down": "将窗格向下移动",
  "Focus Pane Left": "聚焦左侧窗格",
  "Focus Pane Right": "聚焦右侧窗格",
  "Focus Pane Up": "聚焦上方窗格",
  "Focus Pane Down": "聚焦下方窗格",
  "Balance Splits": "平衡分栏",
  "Resize Pane": "调整窗格大小",
  "Move Pane to Tab…": "将窗格移到标签页…",
  "Copy Pane ID": "复制窗格 ID",
  "Send Key": "发送按键",
  "Send Key to Server": "向服务器发送按键",
  "Jump to Previous Prompt": "跳到上一个提示符",
  "Jump to Next Prompt": "跳到下一个提示符",
  "Clear Terminal": "清空终端",
  "Reset Terminal": "重置终端",
  "Enter Mode": "进入模式",
  "Exit Mode": "退出模式",
  "Exit All Modes": "退出所有模式",
  "Toggle Tab Style": "切换标签页样式",
  "Import Theme File": "导入主题文件",
  "Switch Appearance Mode": "切换外观模式",
  "Copy Config File Path": "复制配置文件路径",
  "Reload Config": "重新加载配置",
  "View": "显示",
  "Color Scheme": "配色方案",
  "Tab Style": "标签页样式",
  "Reset Font Size": "重置字体大小",
  "Increase Font Size": "增大字体",
  "Decrease Font Size": "减小字体",
  "Toggle Sidebar": "切换侧边栏",
  "Toggle Activity": "切换活动",
  "Contact…": "联系人…",
  "Passwords…": "密码…",
  "Credit Card…": "信用卡…",
  "Show Activity": "显示活动",
  "Show Previous Tab": "显示上一个标签页",
  "Show Next Tab": "显示下一个标签页",
  "Move Tab Backward": "向后移动标签页",
  "Move Tab Forward": "向前移动标签页",
  "Previous Session": "上一个会话",
  "Next Session": "下一个会话",
  "Rex Beta Diagnostics": "Rex Beta 诊断",
  "Minimize All": "全部最小化",
  "Zoom All": "全部缩放",
  "Fill": "填充",
  "Center": "居中",
  "Move & Resize": "移动与调整大小",
  "Halves": "二分",
  "Left": "左侧",
  "Right": "右侧",
  "Top": "顶部",
  "Bottom": "底部",
  "Quarters_Header": "四分",
  "Top Left": "左上",
  "Top Right": "右上",
  "Bottom Left": "左下",
  "Bottom Right": "右下",
  "Arrange": "排列",
  "Left & Right": "左与右",
  "Left & Quarters": "左与四分",
  "Right & Left": "右与左",
  "Right & Quarters": "右与四分",
  "Top & Bottom": "上与下",
  "Top & Quarters": "上与四分",
  "Bottom & Top": "下与上",
  "Bottom & Quarters": "下与四分",
  "Quarters_MenuItem": "四分",
  "Return to Previous Size": "恢复之前大小",
  "Full Screen Tile": "全屏平铺",
  "Left of Screen": "屏幕左侧",
  "Right of Screen": "屏幕右侧",
  "Remove Window from Set": "从窗口组移除",
  "Arrange in Front": "前置排列",
  "Static Noir": "静态黑色",
]

private func translate(_ value: String) -> String {
  if let translated = translations[value] { return translated }
  if value.hasPrefix("Change the shortcut for ") {
    return "修改 " + translate(String(value.dropFirst("Change the shortcut for ".count))) + " 的快捷键"
  }
  if value.hasPrefix("Record a shortcut for ") {
    return "录制 " + translate(String(value.dropFirst("Record a shortcut for ".count))) + " 的快捷键"
  }
  if value.hasPrefix("Click to record a different shortcut.") { return "点击以录制其他快捷键。" }
  if value.hasPrefix("Click to record a shortcut.") { return "点击以录制快捷键。" }
  if value.contains("Access Rex securely from your other devices.") {
    return value.replacingOccurrences(of: "Access Rex securely from your other devices.", with: "从其他设备安全访问 Rex。")
  }
  if value.contains("Displayed bottom right") {
    return value.replacingOccurrences(of: "Displayed bottom right", with: "显示在右下角")
  }
  if value.contains("Default login shell") {
    return value.replacingOccurrences(of: "Default login shell", with: "默认登录 Shell")
  }
  if value.contains("Filter Shortcuts…") {
    return value.replacingOccurrences(of: "Filter Shortcuts…", with: "筛选快捷键…")
  }
  if value.contains("Filter Shortcuts...") {
    return value.replacingOccurrences(of: "Filter Shortcuts...", with: "筛选快捷键…")
  }
  if value.contains("swift build && swift test") {
    return value.replacingOccurrences(of: "swift build && swift test", with: "Swift 构建 && Swift 测试")
  }
  if value.contains("warning:") {
    return value.replacingOccurrences(of: "warning:", with: "警告：")
  }
  if value.contains("Build complete!") {
    return value.replacingOccurrences(of: "Build complete!", with: "构建完成！")
  }
  if value.contains("Dock Badge") || value.contains("Sound") {
    return value.replacingOccurrences(of: "Dock Badge", with: "程序坞标记")
      .replacingOccurrences(of: "Sound", with: "声音")
  }
  if value == "Default login shell" { return "默认登录 Shell" }
  if value == "Filter Shortcuts…" || value == "Filter Shortcuts..." { return "筛选快捷键…" }
  if value == "Displayed bottom right" { return "显示在右下角" }
  if value == "Command Delete" { return "⌘ Delete" }
  if value == "Command Left Arrow" { return "⌘ ←" }
  if value == "Command Right Arrow" { return "⌘ →" }
  if value == "Option Left Arrow" { return "⌥ ←" }
  if value == "Option Right Arrow" { return "⌥ →" }
  if value.contains(" Option Command ") || value.hasPrefix("Option Command ") {
    return value.replacingOccurrences(of: "Option", with: "⌥")
      .replacingOccurrences(of: "Command", with: "⌘")
      .replacingOccurrences(of: "Left Arrow", with: "←")
      .replacingOccurrences(of: "Right Arrow", with: "→")
      .replacingOccurrences(of: "Up Arrow", with: "↑")
      .replacingOccurrences(of: "Down Arrow", with: "↓")
  }
  if value.contains("Command ") && (value.contains("Arrow") || value.contains("Return")) {
    return value.replacingOccurrences(of: "Command", with: "⌘")
      .replacingOccurrences(of: "Left Arrow", with: "←")
      .replacingOccurrences(of: "Right Arrow", with: "→")
      .replacingOccurrences(of: "Up Arrow", with: "↑")
      .replacingOccurrences(of: "Down Arrow", with: "↓")
      .replacingOccurrences(of: "Return", with: "↩")
  }
  if value.hasPrefix("Running for ") { return "已运行" + value.dropFirst("Running for ".count) }
  return value
}

private typealias LocalizedStringKeyInit = @convention(thin) (String, LocalizedStringKey.Type) -> LocalizedStringKey
@_silgen_name("rxOrigLKLiteralAddress") private func rxOrigLKLiteralAddress() -> UnsafeRawPointer
@_silgen_name("rxOrigLKInitAddress") private func rxOrigLKInitAddress() -> UnsafeRawPointer
private var originalLiteral: LocalizedStringKeyInit?
private var originalInit: LocalizedStringKeyInit?

private typealias TextVerbatimInit = @convention(thin) (String, Text.Type) -> Text
@_silgen_name("rxOrigTextVerbatimAddress") private func rxOrigTextVerbatimAddress() -> UnsafeRawPointer
private var originalTextVerbatim: TextVerbatimInit?

private typealias TextLocalizedResourceInit = @convention(thin) (LocalizedStringResource, Text.Type) -> Text
@_silgen_name("rxOrigTextLocalizedResourceAddress") private func rxOrigTextLocalizedResourceAddress() -> UnsafeRawPointer
private var originalTextLocalizedResource: TextLocalizedResourceInit?

private typealias TextAttributedStringInit = @convention(thin) (AttributedString, Text.Type) -> Text
@_silgen_name("rxOrigTextAttributedStringAddress") private func rxOrigTextAttributedStringAddress() -> UnsafeRawPointer
private var originalTextAttributedString: TextAttributedStringInit?

private func originalKey(_ literal: Bool) -> LocalizedStringKeyInit {
  if literal, let originalLiteral { return originalLiteral }
  if !literal, let originalInit { return originalInit }
  let address = literal ? rxOrigLKLiteralAddress() : rxOrigLKInitAddress()
  let function = unsafeBitCast(address, to: LocalizedStringKeyInit.self)
  if literal { originalLiteral = function } else { originalInit = function }
  return function
}

@_silgen_name("rxHookLKLiteral")
public func rxHookLKLiteral(_ value: consuming String, _ type: LocalizedStringKey.Type) -> LocalizedStringKey {
  return originalKey(true)(translate(value), type)
}

@_silgen_name("rxHookLKInit")
public func rxHookLKInit(_ value: consuming String, _ type: LocalizedStringKey.Type) -> LocalizedStringKey {
  return originalKey(false)(translate(value), type)
}

@_silgen_name("rxHookLR")
public func rxHookLR(_ value: consuming String, _ type: LocalizedStringResource.Type) -> LocalizedStringResource {
  return LocalizedStringResource(String.LocalizationValue(translate(value)), table: nil, locale: Locale.current, bundle: .main, comment: nil)
}

@_silgen_name("rxHookTextVerbatim")
public func rxHookTextVerbatim(_ value: consuming String, _ type: Text.Type) -> Text {
  let original = originalTextVerbatim ?? unsafeBitCast(rxOrigTextVerbatimAddress(), to: TextVerbatimInit.self)
  originalTextVerbatim = original
  let translated = translate(value)
  return original(translated, type)
}

@_silgen_name("rxHookTextLocalizedResource")
public func rxHookTextLocalizedResource(_ value: LocalizedStringResource, _ type: Text.Type) -> Text {
  let original = originalTextLocalizedResource ?? unsafeBitCast(rxOrigTextLocalizedResourceAddress(), to: TextLocalizedResourceInit.self)
  originalTextLocalizedResource = original
  let rendered = String(localized: value)
  let translated = translate(rendered)
  guard translated != rendered else { return original(value, type) }
  let replacement = LocalizedStringResource(String.LocalizationValue(translated), table: nil, locale: Locale.current, bundle: .main, comment: nil)
  return original(replacement, type)
}

@_silgen_name("rxHookTextAttributedString")
public func rxHookTextAttributedString(_ value: AttributedString, _ type: Text.Type) -> Text {
  let original = originalTextAttributedString ?? unsafeBitCast(rxOrigTextAttributedStringAddress(), to: TextAttributedStringInit.self)
  originalTextAttributedString = original
  let rendered = String(value.characters)
  let translated = translate(rendered)
  guard translated != rendered else { return original(value, type) }
  return original(AttributedString(translated), type)
}

@_silgen_name("rxHookTextGeneric")
public func rxHookTextGeneric<S: StringProtocol>(_ value: inout S, _ type: Text.Type) -> Text {
  let translated = translate(String(value))
  return Text(verbatim: translated)
}
