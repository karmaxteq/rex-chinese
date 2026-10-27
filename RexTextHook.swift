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
  "Edit Host": "编辑主机",
  "Changes are saved locally on this Mac.": "更改将保存在此 Mac 本地。",
  "Save": "保存",
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
  "Preferred Hostname": "首选主机名",
  "Tailscale hostname": "Tailscale 主机名",
  "Used to generate the Tailscale address.": "用于生成 Tailscale 地址。",
  "Tags": "标签",
  "Tailscale tags": "Tailscale 标签",
  "Optional. Run as a tagged device so your tailnet’s policy decides who can connect.": "可选。作为带标签的设备运行，由 tailnet 策略决定谁可以连接。",
  "Optional. Run as a tagged device so your tailnet's policy decides who can connect.": "可选。作为带标签的设备运行，由 tailnet 策略决定谁可以连接。",
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
  "New Theme Name": "新主题名称",
  "Untitled Light Theme": "未命名浅色主题",
  "**Untitled Light Theme**": "**未命名浅色主题**",
  "Theme name": "主题名称",
  "Light Theme": "浅色主题",
  "Determined by the theme’s background color.": "由主题背景颜色决定。",
  "Determined by the theme's background color.": "由主题背景颜色决定。",
  "Update the sheet’s appearance as you edit. Turn off to restore the Settings appearance.": "编辑时更新面板外观。关闭后恢复设置外观。",
  "Update the sheet's appearance as you edit. Turn off to restore the Settings appearance.": "编辑时更新面板外观。关闭后恢复设置外观。",
  "Click to choose a color. Drag onto another swatch to swap.": "点击选择颜色。拖动到另一个色板上以交换。",
  "Text": "文本",
  "Cursor Text": "光标文本",
  "Selected Text": "选中文本",
  "ANSI Standard": "ANSI 标准",
  "ANSI Bright": "ANSI 亮色",
  "Black": "黑色",
  "Red": "红色",
  "Green": "绿色",
  "Yellow": "黄色",
  "Blue": "蓝色",
  "Magenta": "品红色",
  "Cyan": "青色",
  "White": "白色",
  "Bright Black": "亮黑色",
  "Bright Red": "亮红色",
  "Bright Green": "亮绿色",
  "Bright Yellow": "亮黄色",
  "Bright Blue": "亮蓝色",
  "Bright Magenta": "亮品红色",
  "Bright Cyan": "亮青色",
  "Bright White": "亮白色",
  "Show extended palette": "显示扩展调色板",
  "Collapsed": "已折叠",
  "Revert…": "还原…",
  "Revert to the initially loaded palette": "还原到最初加载的调色板",
  "Save & Apply": "保存并应用",
  "Save this theme and use it as your light theme": "保存此主题并将其用于浅色主题",
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
  "Extend Always": "始终扩展",
  "Theme": "主题",
  "Ask First": "先询问",
  "Default login shell": "默认登录 Shell",
  "Search fonts": "搜索字体",
  "Monospaced": "等宽字体",
  "All Fonts": "所有字体",
  "Italic": "斜体",
  "Bold": "粗体",
  "Bold Italic": "粗斜体",
  "Bar": "竖线",
  "Underline": "下划线",
  "Off": "关闭",
  "Slow": "慢",
  "Fast": "快",
  "Custom": "自定义",
  "Composes characters": "组合字符",
  "Sends Alt": "发送 Alt",
  "Left sends Alt": "左侧发送 Alt",
  "Right sends Alt": "右侧发送 Alt",
  "Cell Foreground": "单元格前景",
  "Cell Background": "单元格背景",
  "Always Open": "始终打开",
  "Never Open": "从不打开",
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
  "This Mac": "此 Mac",
  "Session Filter": "会话筛选",
  "Filter or create": "筛选或创建…",
  "Filter or create...": "筛选或创建…",
  "Filter or create…": "筛选或创建…",
  "Create a session on This Mac": "在此 Mac 上创建会话",
  "Disconnected": "已断开连接",
  "Couldn’t connect": "无法连接",
  "Couldn't connect": "无法连接",
  "Couldn’t find": "找不到",
  "Couldn't find": "找不到",
  "Couldn’t connect to": "无法连接到",
  "Couldn't connect to": "无法连接到",
  "Retry": "重试",
  "Copy": "复制",
  "Copy ": "复制 ",
  "Shows connection details and Retry": "显示连接详情并重试",
  "Hide Details": "隐藏详情",
  "Show Details": "显示详情",
  "Version": "版本",
  "Commit": "提交",
  "Final SHA-256": "最终 SHA-256",
  "Copy Version": "复制版本",
  "Copy Commit": "复制提交",
  "Copy Final SHA-256": "复制最终 SHA-256",
  "this button also has an action to zoom the window": "此按钮还可用于缩放窗口",
  "zoom the window": "缩放窗口",
  "Add Remote Host…": "添加远程主机…",
  "Add Remote Host...": "添加远程主机…",
  "New Tab": "新建标签页",
  "Go to Directory…": "前往目录…",
  "Go to Directory...": "前往目录…",
  "Close Tab": "关闭标签页",
  "Close Session": "关闭会话",
  "Check for Updates...": "检查更新…",
  "Check for Updates…": "检查更新…",
  "An update is available": "有可用更新",
  "Download": "下载",
  "Stop": "停止",
  "Stop the Rex server?": "停止 Rex 服务器？",
  "All processes running on Rex will be stopped. Anything you have running in your sessions will be lost.": "Rex 中正在运行的所有进程都会被停止。会话中正在运行的任务将丢失。",
  "Stop the Rex server? All processes running on Rex will be stopped. Anything you have running in your sessions will be lost.": "停止 Rex 服务器？Rex 中正在运行的所有进程都会被停止。会话中正在运行的任务将丢失。",
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
  "Move Tab Left": "向左移动标签页",
  "Move Tab Right": "向右移动标签页",
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
  "Settings categories": "设置类别",
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
  "Host URL": "主机 URL",
  "Host name": "主机名称",
  "Host Name": "主机名称",
  "Host icon": "主机图标",
  "Globe": "地球",
  "Tagged builds for testers.": "供测试人员使用的标记版本。",
  "Preview": "预览版",
  "Bleeding Edge": "前沿版",
  "Source Checkout": "源代码检出",
  "Allow Automatic Update Checks": "允许自动检查更新",
  "Check for updates automatically?": "是否自动检查更新？",
  "Checking Included Rex": "正在检查随附的 Rex",
  "Checking Rex App Updates": "正在检查 Rex 应用更新",
  "Checking included Rex": "正在检查随附的 Rex",
  "Checking source checkout": "正在检查源代码检出",
  "Checkout Required": "需要检出",
  "Downloading Rex App Update": "正在下载 Rex 应用更新",
  "Rex App Update Available": "Rex 应用有可用更新",
  "Connecting to Rex Server": "正在连接 Rex 服务器",
  "Rex Server Exited": "Rex 服务器已退出",
  "Rex Server Failed": "Rex 服务器失败",
  "Rex Server Restart Required": "Rex 服务器需要重新启动",
  "Sign out of Tailscale?": "退出 Tailscale？",
  "Change Cursor Blink Interval": "修改光标闪烁间隔",
  "Change Cursor Style": "修改光标样式",
  "Change Interface Style": "修改界面样式",
  "Change Option Key Behavior": "修改 Option 键行为",
  "Change Terminal Font": "修改终端字体",
  "Change Terminal Font Size": "修改终端字体大小",
  "Change Terminal Padding Color": "修改终端内边距颜色",
  "Change Update Channel": "修改更新频道",
  "Collapse Session": "折叠会话",
  "Compact Pane Style": "紧凑窗格样式",
  "Background Color": "背景颜色",
  "Delete Custom Theme": "删除自定义主题",
  "Discard unsaved theme changes?": "放弃未保存的主题更改？",
  "Copied config file path": "已复制配置文件路径",
  "Copied debug info": "已复制调试信息",
  "Copied version info": "已复制版本信息",
  "Copy Configuration File Path": "复制配置文件路径",
  "Copy Remote Address": "复制远程地址",
  "Copy Rex server process identifier": "复制 Rex 服务器进程标识",
  "Copy Rex server version": "复制 Rex 服务器版本",
  "Creating Session": "正在创建会话",
  "Local API": "本地 API",
  "Local API URL": "本地 API URL",
  "Allowed origin": "允许的来源",
  "Add Origin": "添加来源",
  "No GUI Overrides Yet": "还没有图形界面覆盖",
  "Waiting for the next key after": "正在等待下一个按键，当前按键：",
  "Waiting for a key.": "正在等待按键。",
  "Exit Full Screen": "退出全屏",
  "Change Keybinding": "更改快捷键",
  "Migrate theme from Ghostty config": "从 Ghostty 配置迁移主题",
  "Filter custom themes": "筛选自定义主题",
  "Choose a Ghostty theme or an iTerm color file.": "选择 Ghostty 主题或 iTerm 颜色文件。",
  "Enable Terminal Font Smoothing": "启用终端字体平滑",
  "Enable Terminal Font Ligatures": "启用终端连字",
  "Enable Display P3 Color Space": "启用 Display P3 色彩空间",
  "Enable Force Cursor Style": "启用强制光标样式",
  "Enable Autobalance Splits": "启用自动平衡分栏",
  "Enable Focus Follows Mouse": "启用焦点跟随鼠标",
  "Enable Highlight Active Pane": "启用突出显示活动窗格",
  "Enable Text Contrast Correction": "启用文本对比度校正",
  "Show Pane Headers": "显示窗格标题",
  "Hide Pane Headers": "隐藏窗格标题",
  "Disable Text Contrast Correction": "停用文本对比度校正",
  "Disable Highlight Active Pane": "停用突出显示活动窗格",
  "Disable Focus Follows Mouse": "停用焦点跟随鼠标",
  "Disable Autobalance Splits": "停用自动平衡分栏",
  "Disable Force Cursor Style": "停用强制光标样式",
  "Disable Display P3 Color Space": "停用 Display P3 色彩空间",
  "Disable Terminal Font Ligatures": "停用终端连字",
  "Disable Terminal Font Smoothing": "停用终端字体平滑",
  "Disable Rounded Selection Corners": "停用选区圆角",
  "Cursor Blink Interval": "光标闪烁间隔",
  "Set Cursor Blink Interval to": "将光标闪烁间隔设为",
  "Choose a preset or enter a whole number from": "选择预设，或输入一个整数，范围为",
  "Option Key Behavior": "Option 键行为",
  "Select Option Key Behavior": "选择 Option 键行为",
  "Select Cursor Style": "选择光标样式",
  "Keyboard Shortcut": "键盘快捷键",
  "Cancel Recording": "取消录制",
  "Change Shortcut": "更改快捷键",
  "Restore the default shortcut.": "恢复默认快捷键。",
  "Restore Default Shortcut": "恢复默认快捷键",
  "Keep the shortcut as it was.": "保留原快捷键。",
  "Record a shortcut": "录制快捷键",
  "Type Shortcut": "输入快捷键",
  "This release cannot be installed on this Mac.": "此版本无法安装在此 Mac 上。",
  "Rex App Update Failed": "Rex 应用更新失败",
  "Retry Rex App Update": "重试 Rex 应用更新",
  "Check Rex App for Updates": "检查 Rex 应用更新",
  "Rex App Is Up to Date": "Rex 应用已是最新版本",
  "Installing Rex App Update": "正在安装 Rex 应用更新",
  "Preparing Rex App Update": "正在准备 Rex 应用更新",
  "Download Rex Update": "下载 Rex 更新",
  "Restart to Update Rex": "重新启动以更新 Rex",
  "Ready to Check for Updates": "可以检查更新",
  "Installing update": "正在安装更新",
  "Update installed.": "更新已安装。",
  "Your terminal tabs won't be lost": "终端标签页不会丢失",
  "Preparing update": "正在准备更新",
  "Checking for updates": "正在检查更新",
  "Relaunch to Update": "重新启动以更新",
  "Waiting for Rex Server to start.": "正在等待 Rex 服务器启动。",
  "Approve this device in the Tailscale admin console.": "在 Tailscale 管理控制台中批准此设备。",
  "HTTPS status isn’t available.": "HTTPS 状态不可用。",
  "HTTPS status isn't available.": "HTTPS 状态不可用。",
  "Serving over Tailscale.": "正在通过 Tailscale 提供服务。",
  "Waiting for an HTTPS certificate": "正在等待 HTTPS 证书",
  "Then retry serving.": "然后重试共享。",
  "Tailscale isn’t available in this version of Rex.": "此版本的 Rex 不支持 Tailscale。",
  "Tailscale isn't available in this version of Rex.": "此版本的 Rex 不支持 Tailscale。",
  "Not serving over Tailscale.": "未通过 Tailscale 提供服务。",
  "Sign in to Tailscale to start serving.": "登录 Tailscale 以开始共享。",
  "Show pairing QR code": "显示配对二维码",
  "Show QR code to pair a device": "显示用于配对设备的二维码",
  "Signed in to Tailscale": "已登录 Tailscale",
  "Signing out of Tailscale": "正在退出 Tailscale",
  "Removing this Mac’s saved Tailscale login": "正在移除此 Mac 保存的 Tailscale 登录信息",
  "Removing this Mac's saved Tailscale login": "正在移除此 Mac 保存的 Tailscale 登录信息",
  "Ready to connect...": "准备连接…",
  "Finish the process in your browser.": "在浏览器中完成此流程。",
  "Preparing to sign in...": "正在准备登录…",
  "This may take a moment.": "可能需要一点时间。",
  "Start the Rex Server to sign in.": "启动 Rex 服务器以登录。",
  "Choose a hostname and optional tags for this Mac.": "为此 Mac 选择主机名和可选标签。",
  "Use tags like tag:name. A name starts with a letter and uses only letters, numbers, or hyphens.": "使用 tag:name 之类的标签。名称以字母开头，只能包含字母、数字或连字符。",
  "Compatibility hasn’t been checked yet.": "尚未检查兼容性。",
  "Compatibility hasn't been checked yet.": "尚未检查兼容性。",
  "Restart using the server included with this app.": "使用此应用随附的服务器重新启动。",
  "Update Rex.app, or restart from source.": "更新 Rex.app，或从源代码重新启动。",
  "Update Rex.app, or restart using its included server.": "更新 Rex.app，或使用其随附服务器重新启动。",
  "Update the app, or restart from source.": "更新应用，或从源代码重新启动。",
  "Restart from source to reconnect.": "从源代码重新启动以重新连接。",
  "Restart to apply them.": "重新启动以应用更改。",
  "Restart to apply them and enable newer features.": "重新启动以应用更改并启用新功能。",
  "Restart the server to enable them.": "重新启动服务器以启用这些功能。",
  "Running from source checkout": "正在从源代码检出运行",
  "less than a minute": "不到一分钟",
  "Server supports": "服务器支持",
  "Rex.app supports": "Rex.app 支持",
  "Rex.app uses Revision": "Rex.app 使用修订版",
  "Built from source on restart": "重新启动时从源代码构建",
  "Restarting is optional.": "重新启动是可选的。",
  "Choose the Rex server to send calls to": "选择要发送调用的 Rex 服务器",
  "retrying in": "将在…后重试",
  "Start the managed Rex server to open its API stream.": "启动受管理的 Rex 服务器以打开 API 流。",
  "Retry Subscription": "重试订阅",
  "No events received.": "未收到事件。",
  "Subscribing to all sessions": "正在订阅所有会话",
  "Waiting for Rex events.": "正在等待 Rex 事件。",
  "Subscription Failed": "订阅失败",
  "No API calls yet.": "尚无 API 调用。",
  "Blank input is distinct from an empty JSON object.": "空输入不同于空 JSON 对象。",
  "Optional; blank sends no payload": "可选；留空时不发送载荷",
  "Resolved endpoint": "已解析端点",
  "Attached clients": "已附加客户端",
  "Attached at an unknown time": "附加时间未知",
  "Pending Mutations": "待处理变更",
  "Pending Pane Commands": "待处理窗格命令",
  "Launch to First Drawable": "启动到首个可绘制帧",
  "Rex not connected": "Rex 未连接",
  "connection lost": "连接已丢失",
  "Not inspected yet": "尚未检查",
  "Rex installation": "Rex 安装",
  "Grant Permissions for Rex": "授予 Rex 权限",
  "Drag into the list in System Settings to grant access.": "将其拖入系统设置中的列表以授予访问权限。",
  "Full Disk Access": "完全磁盘访问权限",
  "Couldn’t read Rex Server’s permissions:": "无法读取 Rex 服务器的权限：",
  "Couldn't read Rex Server's permissions:": "无法读取 Rex 服务器的权限：",
  "Update Rex to see whether Rex Server has these permissions. You can still grant them in System Settings.": "更新 Rex 以查看 Rex 服务器是否拥有这些权限。你仍可在系统设置中授予这些权限。",
  "Rex Server is too old to report its permissions. You can still grant them, and you’ll see their status after Rex updates.": "Rex 服务器版本过旧，无法报告权限。你仍可授予权限，Rex 更新后即可查看状态。",
  "Rex Server is too old to report its permissions. You can still grant them, and you'll see their status after Rex updates.": "Rex 服务器版本过旧，无法报告权限。你仍可授予权限，Rex 更新后即可查看状态。",
  "Waiting for Rex Server on this Mac to start": "正在等待此 Mac 上的 Rex 服务器启动",
  "Lets command-line tools and agents reach devices on your local network.": "允许命令行工具和智能体访问本地网络上的设备。",
  "Lets command-line tools and agents use the camera.": "允许命令行工具和智能体使用摄像头。",
  "Lets command-line tools and agents record from the microphone.": "允许命令行工具和智能体使用麦克风录音。",
  "Lets command-line tools and agents capture the screen, windows, and system audio.": "允许命令行工具和智能体录制屏幕、窗口和系统音频。",
  "Lets command-line tools and agents open files in protected folders, like ~/Downloads and sandboxed apps’ containers.": "允许命令行工具和智能体打开受保护文件夹中的文件，例如 ~/Downloads 和沙盒应用容器中的文件。",
  "Rex.app is not accepting actions. Turn on Remote Control in its Settings under Rex Server.": "Rex.app 不接受操作。请在“Rex 服务器”设置中打开“远程控制”。",
  "does not offer": "不提供",
  "has no window to act in.": "没有可执行操作的窗口。",
  "isn’t available here right now.": "当前无法使用。",
  "isn't available here right now.": "当前无法使用。",
  "Browser origins allowed to open Rex WebSocket streams.": "允许打开 Rex WebSocket 流的浏览器来源。",
  "Default origin, always allowed": "默认来源，始终允许",
  "No folder selected": "未选择文件夹",
  "Source Checkout Unavailable": "源代码检出不可用",
  "Preparing Source Checkout": "正在准备源代码检出",
  "Runs directly from a local checkout.": "直接从本地检出运行。",
  "Uses the Rex helper included with this app.": "使用此应用中随附的 Rex 辅助程序。",
  "Updates are unavailable in development builds.": "开发版本无法更新。",
  "Finish the current update before changing channels.": "完成当前更新后才能更改频道。",
  "Preparing Rex": "正在准备 Rex",
  "The Rex server is already running.": "Rex 服务器已在运行。",
  "A Rex CLI process actor cannot be launched more than once.": "Rex CLI 进程执行器不能启动多次。",
  "rex server start failed": "rex server 启动失败",
  "Rex returned an invalid start timestamp": "Rex 返回了无效的启动时间戳",
  "Rex returned an invalid server endpoint": "Rex 返回了无效的服务器端点",
  "Rex returned an unsupported server endpoint scheme": "Rex 返回了不受支持的服务器端点协议",
  "Rex returned a Unix socket endpoint in an unsupported format": "Rex 返回了格式不受支持的 Unix 套接字端点",
  "Rex returned an invalid Unix socket endpoint": "Rex 返回了无效的 Unix 套接字端点",
  "this Rex binary does not provide the required server JSON API": "此 Rex 二进制文件不提供所需的服务器 JSON API",
  "Unable to follow Rex server logs:": "无法跟踪 Rex 服务器日志：",
  "Unable to observe Rex server status:": "无法观察 Rex 服务器状态：",
  "the Rex CLI ended without a status": "Rex CLI 结束时没有状态",
  "No Rex launch configuration has been provided.": "未提供 Rex 启动配置。",
  "Remove Host": "移除主机",
  "Remove “": "移除“",
  "”? Removing a host leaves its sessions running on the remote server.": "”？移除主机会使其会话继续在远程服务器上运行。",
  "Removing a host leaves its sessions running on the remote server.": "移除主机会使其会话继续在远程服务器上运行。",
  "Remove “foo”?": "移除“foo”？",
  "Action center": "操作中心",
  "Show full message": "显示完整消息",
  "Collapse message": "折叠消息",
  "No custom themes": "没有自定义主题",
  "Couldn’t load folders": "无法加载文件夹",
  "Couldn't load folders": "无法加载文件夹",
  "Couldn’t load": "无法加载",
  "Couldn't load": "无法加载",
  "You don’t have permission to view": "你没有权限查看",
  "You don't have permission to view": "你没有权限查看",
  "is not a folder": "不是文件夹",
  "No folders named": "没有名为",
  "Loading folders": "正在加载文件夹",
  "Add Remote Host": "添加远程主机",
  "is not an HTTP or HTTPS address": "不是 HTTP 或 HTTPS 地址",
  "Type the address of a Rex host": "输入 Rex 主机地址",
  "Couldn’t Connect": "无法连接",
  "Couldn't Connect": "无法连接",
  "Select Interface Style": "选择界面样式",
  "Press a shortcut for": "按下用于",
  "Choose a Key to Remove It": "选择要移除的按键",
  "Reset to Default": "重置为默认值",
  "Search actions": "搜索操作",
  "Selection Foreground": "选区前景色",
  "Selection Background": "选区背景色",
  "Set copy on selection": "设置选择后复制",
  "Enable Rounded Selection Corners": "启用选区圆角",
  "Select Terminal Padding Color": "选择终端内边距颜色",
  "Select Update Channel": "选择更新频道",
  "Every commit that passes CI. Expect some instability.": "每个通过 CI 的提交。预计会有不稳定。",
  "A native notification when terminal programs send notifications.": "终端程序发送通知时显示系统通知。",
  "Let programs send native notifications with OSC 9 or OSC 777.": "允许程序通过 OSC 9 或 OSC 777 发送系统通知。",
  "A native notification when Rex needs you to sign in to Tailscale.": "Rex 需要你登录 Tailscale 时显示系统通知。",
  "A native notification when a tailnet administrator must approve this Mac.": "Tailscale 网络管理员必须批准此 Mac 时显示系统通知。",
  "A native notification when Tailscale stops or reports an error.": "Tailscale 停止或报告错误时显示系统通知。",
  "A tailnet administrator must approve this device.": "Tailscale 网络管理员必须批准此设备。",
  "Open Rex to finish signing in.": "打开 Rex 以完成登录。",
  "Retry serving over Tailscale": "通过 Tailscale 重试共享",
  "Open Tailscale DNS settings": "打开 Tailscale DNS 设置",
  "Sign out and back in to modify tags.": "退出再重新登录以修改标签。",
  "Check your account and sign-out progress, configure a hostname and sign in, reopen or cancel enrollment, or sign out.": "检查账户和退出登录进度，配置主机名并登录，重新打开或取消注册，或退出登录。",
  "Reopen Tailscale sign-in in your browser": "在浏览器中重新打开 Tailscale 登录",
  "Cancel Tailscale sign-in": "取消 Tailscale 登录",
  "A newer server is available": "有更新的服务器可用",
  "Server and app are incompatible": "服务器与应用不兼容",
  "This server requires a newer Rex.app": "此服务器需要更新版本的 Rex.app",
  "Server settings have changed": "服务器设置已更改",
  "New API features are available": "有新的 API 功能可用",
  "Cannot connect to this server": "无法连接到此服务器",
  "System permissions": "系统权限",
  "Grant System Permissions": "授予系统权限",
  "Pane Action Failed": "窗格操作失败",
  "The pane action failed.": "窗格操作失败。",
  "Terminal Attachment Failed": "终端附加失败",
  "Paste Unsafe Text?": "粘贴不安全文本？",
  "This paste could run commands before you can review them. Paste it anyway?": "此粘贴可能会在你查看前运行命令。仍要粘贴吗？",
  "The terminal stream was interrupted. Reconnecting automatically.": "终端流已中断。正在自动重新连接。",
  "The connection dropped. This terminal keeps its contents and continues where it left off.": "连接已断开。此终端会保留内容并从中断处继续。",
  "Reconnecting": "正在重新连接",
  "Content preserved.": "内容已保留。",
  "No match selected": "未选择匹配项",
  "Searching, no matches yet": "正在搜索，尚无匹配项",
  "Click to resize it to fit this window.": "点击以调整大小，使其适应此窗口。",
  "Sized by another client": "由另一个客户端调整大小",
  "Rex returned an incomplete pane layout.": "Rex 返回了不完整的窗格布局。",
  "The terminal could not be reset.": "无法重置终端。",
  "The tab could not be activated.": "无法激活标签页。",
  "The session could not be moved.": "无法移动会话。",
  "The tab could not be moved.": "无法移动标签页。",
  "The tab could not be closed.": "无法关闭标签页。",
  "The tab could not be created.": "无法创建标签页。",
  "The name could not be changed.": "无法更改名称。",
  "The session could not be closed.": "无法关闭会话。",
  "The session could not be created.": "无法创建会话。",
  "Waiting for the shared server connection to be replaced.": "正在等待共享服务器连接被替换。",
  "Preparing Rex Server": "正在准备 Rex 服务器",
  "Waiting for the local control API to become available.": "正在等待本地控制 API 可用。",
  "Stopping Rex Server": "正在停止 Rex 服务器",
  "Starting Rex Server": "正在启动 Rex 服务器",
  "Rex Server Is Unavailable": "Rex 服务器不可用",
  "Rex Server Is Stopped": "Rex 服务器已停止",
  "Restart the server to use new features": "重新启动服务器以使用新功能",
  "The running Rex server is incompatible with this version of Rex.app.": "正在运行的 Rex 服务器与此版本的 Rex.app 不兼容。",
  "Restart is required.": "需要重新启动。",
  "Restart the Rex server?": "重新启动 Rex 服务器？",
  "This needs the newer server. Restart it and try again.": "需要使用更新的服务器。请重新启动后重试。",
  "Restart Rex Server": "重新启动 Rex 服务器",
  "Rex.app Can’t Talk to the Server": "Rex.app 无法与服务器通信",
  "Rex.app Can't Talk to the Server": "Rex.app 无法与服务器通信",
  "Rex.app Is Older Than the Server": "Rex.app 版本低于服务器",
  "The Rex Server Needs a Restart": "Rex 服务器需要重新启动",
  "No attached clients": "没有附加客户端",
  "Select a session": "选择会话",
  "Inspect the hub's servers and sessions in the main diagnostics view.": "在主诊断视图中检查 Hub 的服务器和会话。",
  "Working Directory": "工作目录",
  "Copy launch command": "复制启动命令",
  "Copy server build commit": "复制服务器构建提交",
  "Copy server build version": "复制服务器构建版本",
  "Connection details are available when the server is ready.": "服务器就绪后即可查看连接详情。",
  "Waiting for server": "正在等待服务器",
  "Not available until the server is ready": "服务器就绪前不可用",
  "Tailscale stopped": "Tailscale 已停止",
  "Approve this device in Tailscale": "在 Tailscale 中批准此设备",
  "Tailscale assigned": "Tailscale 已分配",
  "The Tailscale request timed out. Try again.": "Tailscale 请求超时。请重试。",
  "Tailscale is taking longer than usual. You can keep waiting or cancel.": "Tailscale 所需时间比平时长。你可以继续等待或取消。",
  "Taking longer than usual. If you’ve finished in your browser, Rex is still waiting for Tailscale to confirm.": "所需时间比平时长。如果你已在浏览器中完成操作，Rex 仍在等待 Tailscale 确认。",
  "Taking longer than usual. If you've finished in your browser, Rex is still waiting for Tailscale to confirm.": "所需时间比平时长。如果你已在浏览器中完成操作，Rex 仍在等待 Tailscale 确认。",
]

private func translate(_ value: String) -> String {
  if let translated = translations[value] { return translated }
  // Workspace notifications append a technical payload to the English
  // sentence. Translate the visible/AX prefix and preserve the payload.
  if value.hasPrefix("Copied version info. ") {
    return "已复制版本信息 " + value.dropFirst("Copied version info. ".count)
  }
  if value.hasPrefix("Copied debug info. ") {
    return "已复制调试信息 " + value.dropFirst("Copied debug info. ".count)
  }
  if value.hasPrefix("Copied config file path. ") {
    return "已复制配置文件路径 " + value.dropFirst("Copied config file path. ".count)
  }
  if value.hasPrefix("You don’t have permission to view ") {
    return "你没有权限查看 " + value.dropFirst("You don’t have permission to view ".count)
  }
  if value.hasPrefix("You don't have permission to view ") {
    return "你没有权限查看 " + value.dropFirst("You don't have permission to view ".count)
  }
  if value.hasPrefix("No folders named ") {
    return "没有名为 " + value.dropFirst("No folders named ".count) + " 的文件夹"
  }
  if value.hasSuffix(" is not a folder") {
    return String(value.dropLast(" is not a folder".count)) + " 不是文件夹"
  }
  if value.hasPrefix(" is not an HTTP or HTTPS address") {
    return "不是 HTTP 或 HTTPS 地址" + value.dropFirst(" is not an HTTP or HTTPS address".count)
  }
  if value.hasPrefix("Couldn’t Connect to ") {
    return "无法连接到 " + value.dropFirst("Couldn’t Connect to ".count)
  }
  if value.hasPrefix("Couldn't Connect to ") {
    return "无法连接到 " + value.dropFirst("Couldn't Connect to ".count)
  }
  if value.hasPrefix("Press a shortcut for ") {
    return "按下用于" + value.dropFirst("Press a shortcut for ".count)
  }
  if value.hasPrefix("Another client resized this terminal to ") {
    return "另一个客户端已将此终端调整为 " + value.dropFirst("Another client resized this terminal to ".count)
  }
  if value.hasPrefix("Rex.app includes version ") {
    return "Rex.app 包含版本 " + value.dropFirst("Rex.app includes version ".count)
  }
  if value.hasPrefix("Running server version: ") {
    return "运行中服务器版本：" + value.dropFirst("Running server version: ".count)
  }
  if value.hasPrefix("Connection attempt ") && value.hasSuffix(" failed. Choose to try again now.") {
    let attempt = value.dropFirst("Connection attempt ".count).dropLast(" failed. Choose to try again now.".count)
    return "连接尝试 " + attempt + " 失败。请选择立即重试。"
  }
  if value.hasPrefix("Rex must be updated: ") {
    return "Rex 必须更新：" + value.dropFirst("Rex must be updated: ".count)
  }
  if value.hasPrefix("The Rex server command failed: ") {
    return "Rex 服务器命令失败：" + value.dropFirst("The Rex server command failed: ".count)
  }
  if value.hasPrefix("The Rex server did not become ready: ") {
    return "Rex 服务器未能就绪：" + value.dropFirst("The Rex server did not become ready: ".count)
  }
  if value.hasPrefix("The Rex server could not be launched: ") {
    return "Rex 服务器无法启动：" + value.dropFirst("The Rex server could not be launched: ".count)
  }
  if value.hasPrefix("The Rex server working directory could not be prepared: ") {
    return "Rex 服务器工作目录无法准备：" + value.dropFirst("The Rex server working directory could not be prepared: ".count)
  }
  if value.hasPrefix("The durable host ID is ") {
    return "持久主机 ID 为 " + value.dropFirst("The durable host ID is ".count)
  }
  if value.hasPrefix("Remove “") && value.hasSuffix("”?") {
    return "移除" + value.dropFirst("Remove ".count)
  }
  if value.hasPrefix("Remove '") && value.hasSuffix("'?") {
    return "移除" + value.dropFirst("Remove ".count)
  }
  if value.hasPrefix("Use ") && value.contains(" letters, numbers, or hyphens.") {
    return value.replacingOccurrences(of: " letters, numbers, or hyphens.", with: " 个字母、数字或连字符。")
      .replacingOccurrences(of: "The name can’t begin or end with a hyphen.", with: "名称不能以连字符开头或结尾。")
      .replacingOccurrences(of: "The name can't begin or end with a hyphen.", with: "名称不能以连字符开头或结尾。")
  }
  if value.hasPrefix("Set Cursor Blink Interval to ") {
    return "将光标闪烁间隔设为 " + value.dropFirst("Set Cursor Blink Interval to ".count)
  }
  if value.hasPrefix("Choose a preset or enter a whole number from ") {
    return "选择预设，或输入一个整数，范围为 " + value.dropFirst("Choose a preset or enter a whole number from ".count)
  }
  if value.hasPrefix("Server supports ") {
    return "服务器支持 " + value.dropFirst("Server supports ".count)
  }
  if value.hasPrefix("Rex.app supports ") {
    return "Rex.app 支持 " + value.dropFirst("Rex.app supports ".count)
  }
  if value.hasPrefix("Rex.app uses Revision ") {
    return "Rex.app 使用修订版 " + value.dropFirst("Rex.app uses Revision ".count)
  }
  if value.hasPrefix("Couldn’t read Rex Server’s permissions: ") {
    return "无法读取 Rex 服务器的权限：" + value.dropFirst("Couldn’t read Rex Server’s permissions: ".count)
  }
  if value.hasPrefix("Couldn't read Rex Server's permissions: ") {
    return "无法读取 Rex 服务器的权限：" + value.dropFirst("Couldn't read Rex Server's permissions: ".count)
  }
  if value.hasPrefix("Unable to follow Rex server logs: ") {
    return "无法跟踪 Rex 服务器日志：" + value.dropFirst("Unable to follow Rex server logs: ".count)
  }
  if value.hasPrefix("Unable to observe Rex server status: ") {
    return "无法观察 Rex 服务器状态：" + value.dropFirst("Unable to observe Rex server status: ".count)
  }
  if value.hasPrefix("status exited with ") {
    return "状态退出，结果为 " + value.dropFirst("status exited with ".count)
  }
  if value.hasPrefix("Rex server status is ambiguous (") {
    return "Rex 服务器状态不明确（" + value.dropFirst("Rex server status is ambiguous (".count)
  }
  if value.hasPrefix("Rex server status could not be verified. ") {
    return "无法验证 Rex 服务器状态。" + value.dropFirst("Rex server status could not be verified. ".count)
  }
  if value.hasPrefix("The running Rex server and this Rex.app share no version of the control API.") {
    return "正在运行的 Rex 服务器与此 Rex.app 没有共同的控制 API 版本。" + value.dropFirst("The running Rex server and this Rex.app share no version of the control API.".count)
  }
  if value.hasPrefix("The running Rex server is older than this Rex.app. ") {
    return "正在运行的 Rex 服务器版本低于此 Rex.app。" + value.dropFirst("The running Rex server is older than this Rex.app. ".count)
  }
  if value.hasPrefix("Signing out of Tailscale timed out. ") {
    return "退出 Tailscale 超时。" + value.dropFirst("Signing out of Tailscale timed out. ".count)
  }
  if value.hasPrefix("Changing Tailscale tags timed out. ") {
    return "更改 Tailscale 标签超时。" + value.dropFirst("Changing Tailscale tags timed out. ".count)
  }
  if value.hasPrefix("Rex couldn’t start Tailscale to remove the saved login. ") {
    return "Rex 无法启动 Tailscale 以移除保存的登录信息。" + value.dropFirst("Rex couldn’t start Tailscale to remove the saved login. ".count)
  }
  if value.hasPrefix("Rex couldn't start Tailscale to remove the saved login. ") {
    return "Rex 无法启动 Tailscale 以移除保存的登录信息。" + value.dropFirst("Rex couldn't start Tailscale to remove the saved login. ".count)
  }
  if value == "theme" { return "主题" }
  if value.hasPrefix("Hex value for ") {
    let label = String(value.dropFirst("Hex value for ".count))
    return translate(label) + "的十六进制值"
  }
  if value.hasPrefix("Black #") { return "黑色 " + value.dropFirst("Black".count) }
  if value.hasPrefix("Red #") { return "红色 " + value.dropFirst("Red".count) }
  if value.hasPrefix("Green #") { return "绿色 " + value.dropFirst("Green".count) }
  if value.hasPrefix("Yellow #") { return "黄色 " + value.dropFirst("Yellow".count) }
  if value.hasPrefix("Blue #") { return "蓝色 " + value.dropFirst("Blue".count) }
  if value.hasPrefix("Magenta #") { return "品红色 " + value.dropFirst("Magenta".count) }
  if value.hasPrefix("Cyan #") { return "青色 " + value.dropFirst("Cyan".count) }
  if value.hasPrefix("White #") { return "白色 " + value.dropFirst("White".count) }
  if value.hasPrefix("Bright Black #") { return "亮黑色 " + value.dropFirst("Bright Black".count) }
  if value.hasPrefix("Bright Red #") { return "亮红色 " + value.dropFirst("Bright Red".count) }
  if value.hasPrefix("Bright Green #") { return "亮绿色 " + value.dropFirst("Bright Green".count) }
  if value.hasPrefix("Bright Yellow #") { return "亮黄色 " + value.dropFirst("Bright Yellow".count) }
  if value.hasPrefix("Bright Blue #") { return "亮蓝色 " + value.dropFirst("Bright Blue".count) }
  if value.hasPrefix("Bright Magenta #") { return "亮品红色 " + value.dropFirst("Bright Magenta".count) }
  if value.hasPrefix("Bright Cyan #") { return "亮青色 " + value.dropFirst("Bright Cyan".count) }
  if value.hasPrefix("Bright White #") { return "亮白色 " + value.dropFirst("Bright White".count) }
  if value.hasSuffix(" theme") {
    let base = String(value.dropLast(6))
    let translatedBase = translate(base)
    if translatedBase != base { return translatedBase + "主题" }
  }
  if value == "Session Filter" { return "会话筛选" }
  if value == "Filter or create" || value == "Filter or create..." || value == "Filter or create…" { return "筛选或创建…" }
  if value.hasPrefix("Reconnecting to ") { return "正在重新连接 " + value.dropFirst("Reconnecting to ".count) }
  if value.hasPrefix("Connecting to ") { return "正在连接 " + value.dropFirst("Connecting to ".count) }
  if value.hasPrefix("Connected to ") { return "已连接到 " + value.dropFirst("Connected to ".count) }
  var remoteHostError = value
  remoteHostError = remoteHostError.replacingOccurrences(of: "Couldn’t connect to ", with: "无法连接到 ")
  remoteHostError = remoteHostError.replacingOccurrences(of: "Couldn't connect to ", with: "无法连接到 ")
  remoteHostError = remoteHostError.replacingOccurrences(of: "Couldn’t find ", with: "找不到 ")
  remoteHostError = remoteHostError.replacingOccurrences(of: "Couldn't find ", with: "找不到 ")
  remoteHostError = remoteHostError.replacingOccurrences(of: ". Check your network connection and the host’s address, and make sure Rex is running on the host, then retry.", with: "。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。")
  remoteHostError = remoteHostError.replacingOccurrences(of: ". Check your network connection and the host's address, and make sure Rex is running on the host, then retry.", with: "。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。")
  if remoteHostError != value { return remoteHostError }
  if value.hasPrefix("Create a session on ") { return "在 " + translate(String(value.dropFirst("Create a session on ".count))) + " 上创建会话" }
  if value.hasPrefix("Loading Sessions on ") { return "正在加载 " + value.dropFirst("Loading Sessions on ".count) + " 上的会话" }
  if value.hasPrefix("Running for ") { return "已运行" + value.dropFirst("Running for ".count) }
  if value.hasPrefix("Exited with status ") { return "已退出，状态码 " + value.dropFirst("Exited with status ".count) }
  if value.hasPrefix("Connection warning for ") { return "连接警告：" + value.dropFirst("Connection warning for ".count) }
  if value.hasPrefix("Connection errors: ") { return "连接错误：" + value.dropFirst("Connection errors: ".count) }
  if value.hasPrefix("Tailscale failed: ") { return "Tailscale 失败：" + value.dropFirst("Tailscale failed: ".count) }
  if value.hasPrefix("Tailscale assigned ") { return "Tailscale 已分配 " + value.dropFirst("Tailscale assigned ".count) }
  if value.hasPrefix("Restart required: ") { return "需要重新启动：" + value.dropFirst("Restart required: ".count) }
  if value.hasPrefix("Rex Server is running as part of ") { return "Rex 服务器属于 " + value.dropFirst("Rex Server is running as part of ".count) }
  if value.hasPrefix("Restarted the Rex server for Rex ") { return "已为 Rex " + value.dropFirst("Restarted the Rex server for Rex ".count) + " 重新启动服务器" }
  if value.hasPrefix("Update Rex on the server to use ") { return "更新服务器上的 Rex 以使用 " + value.dropFirst("Update Rex on the server to use ".count) }
  if value.hasPrefix("Set Cursor Blink Interval to ") { return "将光标闪烁间隔设为 " + value.dropFirst("Set Cursor Blink Interval to ".count) }
  if value.hasPrefix("Set Terminal Font Size to ") { return "将终端字体大小设为 " + value.dropFirst("Set Terminal Font Size to ".count) }
  if value.hasPrefix("Server Version ") { return value.replacingOccurrences(of: "Server Version", with: "服务器版本").replacingOccurrences(of: "API Version", with: "API 版本").replacingOccurrences(of: "Revision", with: "修订版") }
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
