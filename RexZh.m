#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <string.h>
#include <objc/message.h>

static NSString *RXTranslate(NSString *s) {
    if (![s isKindOfClass:[NSString class]] || s.length == 0) return s;
    static NSDictionary *map;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        map = @{
            @"Change Session": @"切换会话",
            @"Change Session...": @"切换会话…",
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
            @"Preferred Hostname": @"首选主机名",
            @"Tailscale hostname": @"Tailscale 主机名",
            @"Used to generate the Tailscale address.": @"用于生成 Tailscale 地址。",
            @"Tags": @"标签",
            @"Tailscale tags": @"Tailscale 标签",
            @"Optional. Run as a tagged device so your tailnet’s policy decides who can connect.": @"可选。作为带标签的设备运行，由 tailnet 策略决定谁可以连接。",
            @"Optional. Run as a tagged device so your tailnet's policy decides who can connect.": @"可选。作为带标签的设备运行，由 tailnet 策略决定谁可以连接。",
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
            @"Edit Host": @"编辑主机",
            @"Changes are saved locally on this Mac.": @"更改将保存在此 Mac 本地。",
            @"Save": @"保存",
            @"Expose settings for development and debugging.": @"显示用于开发和调试的设置。",
            @"Appearance": @"外观",
            @"Color scheme": @"配色方案",
            @"Light": @"浅色",
            @"Dark": @"深色",
            @"Auto": @"自动",
            @"Create Session": @"创建会话",
            @"No Sessions": @"没有会话",
            @"Add Remote Host…": @"添加远程主机…",
            @"Add Remote Host...": @"添加远程主机…",
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
            @"This Mac": @"此 Mac",
            @"Session Filter": @"会话筛选",
            @"Filter or create": @"筛选或创建…",
            @"Filter or create...": @"筛选或创建…",
            @"Filter or create…": @"筛选或创建…",
            @"Create a session on This Mac": @"在此 Mac 上创建会话",
            @"Disconnected": @"已断开连接",
            @"Couldn’t connect": @"无法连接",
            @"Couldn't connect": @"无法连接",
            @"Couldn’t find": @"找不到",
            @"Couldn't find": @"找不到",
            @"Couldn’t connect to": @"无法连接到",
            @"Couldn't connect to": @"无法连接到",
            @"Retry": @"重试",
            @"Copy": @"复制",
            @"Copy ": @"复制 ",
            @"Shows connection details and Retry": @"显示连接详情并重试",
            @"Hide Details": @"隐藏详情",
            @"Show Details": @"显示详情",
            @"Version": @"版本",
            @"Commit": @"提交",
            @"Final SHA-256": @"最终 SHA-256",
            @"Copy Version": @"复制版本",
            @"Copy Commit": @"复制提交",
            @"Copy Final SHA-256": @"复制最终 SHA-256",
            @"this button also has an action to zoom the window": @"此按钮还可用于缩放窗口",
            @"zoom the window": @"缩放窗口",
            @"Rename Session": @"重命名会话",
            @"Rename Tab": @"重命名标签页",
            @"Search commands": @"搜索命令",
            @"Search commands...": @"搜索命令…",
            @"Search commands, sessions, and tabs...": @"搜索命令、会话和标签页…",
            @"Search commands, sessions, and tabs…": @"搜索命令、会话和标签页…",
            @"Commands": @"命令",
            @"Tabs": @"标签页",
            @"Tabs Above": @"标签页上方",
            @"Tabs on Left Side": @"标签页左侧",
            @"Tabs on Right Side": @"标签页右侧",
            @"Comfortable Pane Style": @"舒适窗格样式",
            @"Settings...": @"设置…",
            @"Grant System Permissions...": @"授予系统权限…",
            @"Add": @"添加",
            @"Rename Session…": @"重命名会话…",
            @"Close Session": @"关闭会话",
            @"Customize View": @"自定义视图",
            @"Change Theme…": @"更改主题…",
            @"Interface Style": @"界面样式",
            @"Tab Buttons": @"标签页按钮",
            @"Pane Buttons": @"窗格按钮",
            @"About Rex Beta": @"关于Rex Beta",
            @"About Rex Beta…": @"关于Rex Beta…",
            @"Check for Updates...": @"检查更新…",
            @"Check for Updates…": @"检查更新…",
            @"An update is available": @"有可用更新",
            @"Download": @"下载",
            @"Download Update": @"下载更新",
            @"Stop": @"停止",
            @"Stop the Rex server?": @"停止 Rex 服务器？",
            @"All processes running on Rex will be stopped. Anything you have running in your sessions will be lost.": @"Rex 中正在运行的所有进程都会被停止。会话中正在运行的任务将丢失。",
            @"Stop the Rex server? All processes running on Rex will be stopped. Anything you have running in your sessions will be lost.": @"停止 Rex 服务器？Rex 中正在运行的所有进程都会被停止。会话中正在运行的任务将丢失。",
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
            @"Settings navigation": @"设置导航",
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
            @"Rex Server": @"Rex 服务器",
            @"Interface style": @"界面样式",
            @"Glass": @"玻璃",
            @"Classic": @"经典",
            @"Tint with theme": @"使用主题着色",
            @"Tint with the theme": @"使用主题着色",
            @"Tab style": @"标签页样式",
            @"Above": @"上方",
            @"Left Side": @"左侧",
            @"Right Side": @"右侧",
            @"Use color for tab icons": @"为标签页图标使用颜色",
            @"Shell icon theme": @"Shell 图标主题",
            @"Always": @"始终",
            @"For active panes": @"对活动窗格",
            @"For active tabs": @"对活动标签页",
            @"Never": @"从不",
            @"Default": @"默认",
            @"Regular": @"常规",
            @"Block": @"块状",
            @"Normal": @"正常",
            @"Automatic (by keyboard layout)": @"自动（根据键盘布局）",
            @"Extend": @"扩展",
            @"Extend Always": @"始终扩展",
            @"Theme": @"主题",
            @"Ask First": @"先询问",
            @"Default login shell": @"默认登录 Shell",
            @"Search fonts": @"搜索字体",
            @"Monospaced": @"等宽字体",
            @"All Fonts": @"所有字体",
            @"Italic": @"斜体",
            @"Bold": @"粗体",
            @"Bold Italic": @"粗斜体",
            @"Bar": @"竖线",
            @"Underline": @"下划线",
            @"Off": @"关闭",
            @"Slow": @"慢",
            @"Fast": @"快",
            @"Custom": @"自定义",
            @"Composes characters": @"组合字符",
            @"Sends Alt": @"发送 Alt",
            @"Left sends Alt": @"左侧发送 Alt",
            @"Right sends Alt": @"右侧发送 Alt",
            @"Cell Foreground": @"单元格前景",
            @"Cell Background": @"单元格背景",
            @"Always Open": @"始终打开",
            @"Never Open": @"从不打开",
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
            @"Dynamic": @"动态",
            @"Choose…": @"选择…",
            @"Choose...": @"选择…",
            @"Startup command": @"启动命令",
            @"Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal’s working directory when available. Otherwise, they use the server’s default directory.": @"可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
            @"Filter Shortcuts": @"筛选快捷键",
            @"Filter Shortcuts…": @"筛选快捷键…",
            @"Displayed bottom right": @"显示在右下角",
            @"Open Session on Web…": @"在网页上打开会话…",
            @"Open Session on Web...": @"在网页上打开会话…",
            @"Switch Host": @"切换主机",
            @"Remove Host…": @"移除主机…",
            @"Remove Host...": @"移除主机…",
            @"Opens Running settings": @"打开“运行中”设置",
            @"Opens Blocked settings": @"打开“已阻塞”设置",
            @"Opens Error settings": @"打开“错误”设置",
            @"Opens Done settings": @"打开“已完成”设置",
            @"Dock Badge and Sound": @"程序坞标记和声音",
            @"Dock Badge和Sound": @"程序坞标记和声音",
            @"A shortcut recorded here takes priority over file-based configuration. Search for a key, such as cmd+k, to see everything bound to it. The first result is the one the key performs.": @"此处记录的快捷键优先于文件配置。搜索 cmd+k 等按键即可查看所有绑定项；第一个结果就是该按键执行的操作。",
            @"Window": @"窗口",
            @"New Window": @"新建窗口",
            @"Move Tab to New Window": @"将标签页移到新窗口",
            @"Close Window": @"关闭窗口",
            @"Go to Directory…": @"前往目录…",
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
            @"on": @"开",
            @"off": @"关",
            @"Light Mode": @"浅色模式",
            @"Dark Mode": @"深色模式",
            @"— Active": @"— 当前",
            @"New Light Theme": @"新建浅色主题",
            @"New Dark Theme": @"新建深色主题",
            @"New Theme Name": @"新主题名称",
            @"Untitled Light Theme": @"未命名浅色主题",
            @"**Untitled Light Theme**": @"**未命名浅色主题**",
            @"Theme name": @"主题名称",
            @"Light Theme": @"浅色主题",
            @"Determined by the theme’s background color.": @"由主题背景颜色决定。",
            @"Determined by the theme's background color.": @"由主题背景颜色决定。",
            @"Update the sheet’s appearance as you edit. Turn off to restore the Settings appearance.": @"编辑时更新面板外观。关闭后恢复设置外观。",
            @"Update the sheet's appearance as you edit. Turn off to restore the Settings appearance.": @"编辑时更新面板外观。关闭后恢复设置外观。",
            @"Click to choose a color. Drag onto another swatch to swap.": @"点击选择颜色。拖动到另一个色板上以交换。",
            @"Text": @"文本",
            @"Cursor Text": @"光标文本",
            @"Selected Text": @"选中文本",
            @"ANSI Standard": @"ANSI 标准",
            @"ANSI Bright": @"ANSI 亮色",
            @"Black": @"黑色",
            @"Red": @"红色",
            @"Green": @"绿色",
            @"Yellow": @"黄色",
            @"Blue": @"蓝色",
            @"Magenta": @"品红色",
            @"Cyan": @"青色",
            @"White": @"白色",
            @"Bright Black": @"亮黑色",
            @"Bright Red": @"亮红色",
            @"Bright Green": @"亮绿色",
            @"Bright Yellow": @"亮黄色",
            @"Bright Blue": @"亮蓝色",
            @"Bright Magenta": @"亮品红色",
            @"Bright Cyan": @"亮青色",
            @"Bright White": @"亮白色",
            @"Show extended palette": @"显示扩展调色板",
            @"Collapsed": @"已折叠",
            @"Revert…": @"还原…",
            @"Revert to the initially loaded palette": @"还原到最初加载的调色板",
            @"Save & Apply": @"保存并应用",
            @"Save this theme and use it as your light theme": @"保存此主题并将其用于浅色主题",
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
            @"Insert Path…": @"插入路径…",
            @"Find": @"查找",
            @"Find…": @"查找…",
            @"Find Next": @"查找下一个",
            @"Find Previous": @"查找上一个",
            @"Filter Page": @"筛选页面",
            @"AutoFill": @"自动填充",
            @"Start Dictation…": @"开始听写…",
            @"Emoji & Symbols": @"表情与符号",
            @"Refresh Sessions": @"刷新会话",
            @"Pane": @"窗格",
            @"Split Left": @"向左分栏",
            @"Split Up": @"向上分栏",
            @"Split Best Fit": @"最佳分栏",
            @"Focus Left": @"聚焦左侧窗格",
            @"Focus Right": @"聚焦右侧窗格",
            @"Focus Up": @"聚焦上方窗格",
            @"Focus Down": @"聚焦下方窗格",
            @"Focus Previous Pane": @"聚焦上一个窗格",
            @"Focus Next Pane": @"聚焦下一个窗格",
            @"Move Pane Left": @"将窗格向左移动",
            @"Move Pane Right": @"将窗格向右移动",
            @"Move Pane Up": @"将窗格向上移动",
            @"Move Pane Down": @"将窗格向下移动",
            @"Focus Pane Left": @"聚焦左侧窗格",
            @"Focus Pane Right": @"聚焦右侧窗格",
            @"Focus Pane Up": @"聚焦上方窗格",
            @"Focus Pane Down": @"聚焦下方窗格",
            @"Balance Splits": @"平衡分栏",
            @"Resize Pane": @"调整窗格大小",
            @"Move Pane to Tab…": @"将窗格移到标签页…",
            @"Copy Pane ID": @"复制窗格 ID",
            @"Send Key": @"发送按键",
            @"Send Key to Server": @"向服务器发送按键",
            @"Jump to Previous Prompt": @"跳到上一个提示符",
            @"Jump to Next Prompt": @"跳到下一个提示符",
            @"Clear Terminal": @"清空终端",
            @"Reset Terminal": @"重置终端",
            @"Enter Mode": @"进入模式",
            @"Exit Mode": @"退出模式",
            @"Exit All Modes": @"退出所有模式",
            @"Toggle Tab Style": @"切换标签页样式",
            @"Import Theme File": @"导入主题文件",
            @"Switch Appearance Mode": @"切换外观模式",
            @"Copy Config File Path": @"复制配置文件路径",
            @"No GUI Overrides Yet": @"还没有图形界面覆盖",
            @"Copy Shortcuts as Lua": @"将快捷键复制为 Lua",
            @"Reset All…": @"全部重置…",
            @"Reload Config": @"重新加载配置",
            @"View": @"显示",
            @"Color Scheme": @"配色方案",
            @"Tab Style": @"标签页样式",
            @"Pane Style": @"窗格样式",
            @"Reset Font Size": @"重置字体大小",
            @"Increase Font Size": @"增大字体",
            @"Decrease Font Size": @"减小字体",
            @"Toggle Sidebar": @"切换侧边栏",
            @"Toggle Activity": @"切换活动",
            @"Rex Help": @"Rex 帮助",
            @"Surface & Content": @"表面与内容",
            @"Contact…": @"联系人…",
            @"Passwords…": @"密码…",
            @"Credit Card…": @"信用卡…",
            @"Show Activity": @"显示活动",
            @"Show Previous Tab": @"显示上一个标签页",
            @"Show Next Tab": @"显示下一个标签页",
            @"Move Tab Backward": @"向后移动标签页",
            @"Move Tab Forward": @"向前移动标签页",
            @"Move Tab Left": @"向左移动标签页",
            @"Move Tab Right": @"向右移动标签页",
            @"Previous Session": @"上一个会话",
            @"Next Session": @"下一个会话",
            @"Rex Beta Diagnostics": @"Rex Beta 诊断",
            @"Rex Beta Version": @"Rex Beta 版本",
            @"Minimize All": @"全部最小化",
            @"Zoom All": @"全部缩放",
            @"Fill": @"填充",
            @"Center": @"居中",
            @"Move & Resize": @"移动与调整大小",
            @"Halves": @"二分",
            @"Left": @"左侧",
            @"Right": @"右侧",
            @"Top": @"顶部",
            @"Bottom": @"底部",
            @"Quarters_Header": @"四分",
            @"Top Left": @"左上",
            @"Top Right": @"右上",
            @"Bottom Left": @"左下",
            @"Bottom Right": @"右下",
            @"Arrange": @"排列",
            @"Left & Right": @"左与右",
            @"Left & Quarters": @"左与四分",
            @"Right & Left": @"右与左",
            @"Right & Quarters": @"右与四分",
            @"Top & Bottom": @"上与下",
            @"Top & Quarters": @"上与四分",
            @"Bottom & Top": @"下与上",
            @"Bottom & Quarters": @"下与四分",
            @"Quarters_MenuItem": @"四分",
            @"Return to Previous Size": @"恢复之前大小",
            @"Full Screen Tile": @"全屏平铺",
            @"Left of Screen": @"屏幕左侧",
            @"Right of Screen": @"屏幕右侧",
            @"Remove Window from Set": @"从窗口组移除",
            @"Enter Full Screen": @"进入全屏",
            @"Split Pane Best Fit": @"最佳分栏",
            @"Change Keybinding": @"更改快捷键",
            @"Action": @"操作",
            @"Paste": @"粘贴",
            @"Arrange in Front": @"前置排列",
            @"Merino Light": @"Merino 浅色",
            @"Alpine Milk": @"Alpine 牛奶",
            @"Buttercream Diner": @"奶油餐厅",
            @"Coastal Linen": @"海岸亚麻",
            @"Glacier Mint": @"冰川薄荷",
            @"Ivory Gallery": @"象牙画廊",
            @"Lavender Postcard": @"薰衣草明信片",
            @"Newsprint Fog": @"报纸薄雾",
            @"Orchard Breeze": @"果园微风",
            @"Peach Veranda": @"桃色阳台",
            @"Porcelain Morning": @"瓷器晨曦",
            @"Silver Point Light": @"银点浅色",
            @"Sunlit Parchment": @"阳光羊皮纸",
            @"Terracotta Noon": @"陶土正午",
            @"Merino Dark": @"Merino 深色",
            @"Abyssal Trench": @"深渊海沟",
            @"Basalt Shore": @"玄武岩海岸",
            @"Cathode Amber": @"阴极琥珀",
            @"Charcoal Atelier": @"炭黑工坊",
            @"Cinder Peak": @"煤渣峰",
            @"Cobalt Foundry": @"钴蓝铸造厂",
            @"Ember Hollow": @"余烬谷",
            @"Heliotrope Haze": @"天芥菜薄雾",
            @"Ink Meridian": @"墨色子午线",
            @"Juniper Smoke": @"杜松烟",
            @"Midnight Tundra": @"午夜苔原",
            @"Misty Forest": @"迷雾森林",
            @"Moss Cathedral": @"苔藓大教堂",
            @"Neon Arcade": @"霓虹街机",
            @"Nocturne Rose": @"夜曲玫瑰",
            @"Oxblood Library": @"牛血红图书馆",
            @"Petrol Lagoon": @"石油蓝泻湖",
            @"Phosphor Archive": @"磷光档案",
            @"Polar Aurora": @"极地极光",
            @"Roasted Umber": @"烘烤赭石",
            @"Saffron Nightfall": @"藏红花夜幕",
            @"Silver Point Dark": @"银点深色",
            @"Sonoran Dusk": @"索诺兰暮色",
            @"Static Noir": @"静态黑色",
            @"Velvet Dusk": @"天鹅绒暮色",
            @"Whitby Bay": @"惠特比湾",
            // Recent settings and remote-host labels are kept in the runtime map
            // as well as Localizable.strings so accessibility descriptions and
            // composite SwiftUI labels use the same Simplified Chinese text.
            @"Panes": @"窗格",
            @"App Icon": @"应用图标",
            @"Default — Dynamic": @"默认 — 动态",
            @"Bright": @"明亮",
            @"Twilight": @"暮色",
            @"Fill available space": @"填充可用空间",
            @"Show tab icons": @"显示标签页图标",
            @"Show pane headers": @"显示窗格标题",
            @"Match program backgrounds": @"匹配程序背景",
            @"Fade panes for inactive windows": @"淡化非活动窗口的窗格",
            @"Highlight active pane": @"突出显示活动窗格",
            @"Autobalance splits": @"自动平衡分栏",
            @"Focus follows mouse": @"焦点跟随鼠标",
            @"Show window on launch": @"启动时显示窗口",
            @"Host URL": @"主机 URL",
            @"Host name": @"主机名称",
            @"Host Name": @"主机名称",
            @"Host icon": @"主机图标",
            @"Globe": @"地球",
            @"Tagged builds for testers.": @"供测试人员使用的标记版本。",
            @"Preview": @"预览版",
            @"Bleeding Edge": @"前沿版",
            @"Source Checkout": @"源代码检出",
            @"Allow Automatic Update Checks": @"允许自动检查更新",
            @"Check for updates automatically?": @"是否自动检查更新？",
            @"Checking Included Rex": @"正在检查随附的 Rex",
            @"Checking Rex App Updates": @"正在检查 Rex 应用更新",
            @"Checking included Rex": @"正在检查随附的 Rex",
            @"Checking source checkout": @"正在检查源代码检出",
            @"Checkout Required": @"需要检出",
            @"Downloading Rex App Update": @"正在下载 Rex 应用更新",
            @"Rex App Update Available": @"Rex 应用有可用更新",
            @"Connecting to Rex Server": @"正在连接 Rex 服务器",
            @"Rex Server Exited": @"Rex 服务器已退出",
            @"Rex Server Failed": @"Rex 服务器失败",
            @"Rex Server Restart Required": @"Rex 服务器需要重新启动",
            @"Sign out of Tailscale?": @"退出 Tailscale？",
            @"Change Cursor Blink Interval": @"修改光标闪烁间隔",
            @"Change Cursor Style": @"修改光标样式",
            @"Change Interface Style": @"修改界面样式",
            @"Change Option Key Behavior": @"修改 Option 键行为",
            @"Change Terminal Font": @"修改终端字体",
            @"Change Terminal Font Size": @"修改终端字体大小",
            @"Change Terminal Padding Color": @"修改终端内边距颜色",
            @"Change Update Channel": @"修改更新频道",
            @"Collapse Session": @"折叠会话",
            @"Compact Pane Style": @"紧凑窗格样式",
            @"Background Color": @"背景颜色",
            @"Delete Custom Theme": @"删除自定义主题",
            @"Discard unsaved theme changes?": @"放弃未保存的主题更改？",
            @"Copied config file path": @"已复制配置文件路径",
            @"Copied debug info": @"已复制调试信息",
            @"Copied version info": @"已复制版本信息",
            @"Copy Configuration File Path": @"复制配置文件路径",
            @"Copy Remote Address": @"复制远程地址",
            @"Copy Rex server process identifier": @"复制 Rex 服务器进程标识",
            @"Copy Rex server version": @"复制 Rex 服务器版本",
            @"Creating Session": @"正在创建会话",
            @"Local API": @"本地 API",
            @"Local API URL": @"本地 API URL",
            @"Allowed origin": @"允许的来源",
            @"Add Origin": @"添加来源",
            @"Update Channel Tagged builds for testers.": @"更新频道 供测试人员使用的标记版本。",
            @"Local API URL unix:///Users/a1/Library/Application Support/rex/server.sock": @"本地 API URL unix:///Users/a1/Library/Application Support/rex/server.sock",
        };
    });
    NSString *exact = map[s];
    if (exact) return exact;
    // Workspace notifications append the copied payload to the English
    // sentence. Keep the payload (version, commit, or path) untouched while
    // translating the sentence prefix used by both visible and AX surfaces.
    if ([s hasPrefix:@"Copied version info. "]) {
        return [NSString stringWithFormat:@"已复制版本信息 %@", [s substringFromIndex:21]];
    }
    if ([s hasPrefix:@"Copied debug info. "]) {
        return [NSString stringWithFormat:@"已复制调试信息 %@", [s substringFromIndex:19]];
    }
    if ([s hasPrefix:@"Copied config file path. "]) {
        return [NSString stringWithFormat:@"已复制配置文件路径 %@", [s substringFromIndex:25]];
    }
    if ([s isEqualToString:@"theme"]) return @"主题";
    if ([s hasPrefix:@"Rex Beta Version "]) {
        return [NSString stringWithFormat:@"Rex Beta 版本 %@", [s substringFromIndex:17]];
    }
    if ([s hasPrefix:@"Version "]) {
        return [NSString stringWithFormat:@"版本 %@", [s substringFromIndex:8]];
    }
    if ([s hasPrefix:@"Copy "]) {
        NSString *suffix = [s substringFromIndex:5];
        return [NSString stringWithFormat:@"复制%@", RXTranslate(suffix)];
    }
    if ([s hasPrefix:@"Hex value for "]) {
        NSString *label = [s substringFromIndex:14];
        return [NSString stringWithFormat:@"%@的十六进制值", RXTranslate(label)];
    }
    if ([s hasPrefix:@"Black #"]) return [NSString stringWithFormat:@"黑色%@", [s substringFromIndex:5]];
    if ([s hasPrefix:@"Red #"]) return [NSString stringWithFormat:@"红色%@", [s substringFromIndex:4]];
    if ([s hasPrefix:@"Green #"]) return [NSString stringWithFormat:@"绿色%@", [s substringFromIndex:6]];
    if ([s hasPrefix:@"Yellow #"]) return [NSString stringWithFormat:@"黄色%@", [s substringFromIndex:7]];
    if ([s hasPrefix:@"Blue #"]) return [NSString stringWithFormat:@"蓝色%@", [s substringFromIndex:5]];
    if ([s hasPrefix:@"Magenta #"]) return [NSString stringWithFormat:@"品红色%@", [s substringFromIndex:8]];
    if ([s hasPrefix:@"Cyan #"]) return [NSString stringWithFormat:@"青色%@", [s substringFromIndex:4]];
    if ([s hasPrefix:@"White #"]) return [NSString stringWithFormat:@"白色%@", [s substringFromIndex:5]];
    if ([s hasPrefix:@"Bright Black #"]) return [NSString stringWithFormat:@"亮黑色%@", [s substringFromIndex:12]];
    if ([s hasPrefix:@"Bright Red #"]) return [NSString stringWithFormat:@"亮红色%@", [s substringFromIndex:10]];
    if ([s hasPrefix:@"Bright Green #"]) return [NSString stringWithFormat:@"亮绿色%@", [s substringFromIndex:12]];
    if ([s hasPrefix:@"Bright Yellow #"]) return [NSString stringWithFormat:@"亮黄色%@", [s substringFromIndex:13]];
    if ([s hasPrefix:@"Bright Blue #"]) return [NSString stringWithFormat:@"亮蓝色%@", [s substringFromIndex:11]];
    if ([s hasPrefix:@"Bright Magenta #"]) return [NSString stringWithFormat:@"亮品红色%@", [s substringFromIndex:14]];
    if ([s hasPrefix:@"Bright Cyan #"]) return [NSString stringWithFormat:@"亮青色%@", [s substringFromIndex:11]];
    if ([s hasPrefix:@"Bright White #"]) return [NSString stringWithFormat:@"亮白色%@", [s substringFromIndex:12]];
    if ([s hasSuffix:@" theme"]) {
        NSString *base = [s substringToIndex:s.length - 6];
        NSString *translatedBase = RXTranslate(base);
        if (translatedBase.length && ![translatedBase isEqualToString:base]) return [translatedBase stringByAppendingString:@"主题"];
    }
    NSString *original = s;
    if ([s containsString:@"Light Mode"]) s = [s stringByReplacingOccurrencesOfString:@"Light Mode" withString:@"浅色模式"];
    if ([s containsString:@"Dark Mode"]) s = [s stringByReplacingOccurrencesOfString:@"Dark Mode" withString:@"深色模式"];
    if ([s containsString:@"— Active"]) s = [s stringByReplacingOccurrencesOfString:@"— Active" withString:@"— 当前"];
    if ([s containsString:@"Import a Ghostty or iTerm theme file"]) s = [s stringByReplacingOccurrencesOfString:@"Import a Ghostty or iTerm theme file" withString:@"导入 Ghostty 或 iTerm 主题文件"];
    if ([s containsString:@"Themes are matched to an appearance based on their background color."]) s = [s stringByReplacingOccurrencesOfString:@"Themes are matched to an appearance based on their background color." withString:@"主题会根据背景颜色匹配到相应外观。"];
    if ([s containsString:@"Access Rex securely from your other devices."]) s = [s stringByReplacingOccurrencesOfString:@"Access Rex securely from your other devices." withString:@"从其他设备安全访问 Rex。"];
    if ([s containsString:@"Displayed bottom right"]) s = [s stringByReplacingOccurrencesOfString:@"Displayed bottom right" withString:@"显示在右下角"];
    if ([s containsString:@"Default login shell"]) s = [s stringByReplacingOccurrencesOfString:@"Default login shell" withString:@"默认登录 Shell"];
    if ([s containsString:@"Filter Shortcuts…"]) s = [s stringByReplacingOccurrencesOfString:@"Filter Shortcuts…" withString:@"筛选快捷键…"];
    if ([s containsString:@"Filter Shortcuts..."]) s = [s stringByReplacingOccurrencesOfString:@"Filter Shortcuts..." withString:@"筛选快捷键…"];
    if ([s containsString:@"swift build && swift test"]) s = [s stringByReplacingOccurrencesOfString:@"swift build && swift test" withString:@"Swift 构建 && Swift 测试"];
    if ([s containsString:@"warning:"]) s = [s stringByReplacingOccurrencesOfString:@"warning:" withString:@"警告："];
    if ([s containsString:@"Build complete!"]) s = [s stringByReplacingOccurrencesOfString:@"Build complete!" withString:@"构建完成！"];
    if (![s isEqualToString:original]) return s;
    NSString *remoteHostError = s;
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn’t connect to " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn't connect to " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn’t find " withString:@"找不到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn't find " withString:@"找不到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@". Check your network connection and the host’s address, and make sure Rex is running on the host, then retry." withString:@"。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。"];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@". Check your network connection and the host's address, and make sure Rex is running on the host, then retry." withString:@"。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。"];
    if (![remoteHostError isEqualToString:s]) return remoteHostError;
    if ([s hasPrefix:@"Check for Updates"]) return @"检查更新…";
    if ([s hasSuffix:@"、Running"]) return [NSString stringWithFormat:@"%@、运行中", [s substringToIndex:s.length - 8]];
    if ([s hasPrefix:@"Running for "]) return [NSString stringWithFormat:@"已运行%@", [s substringFromIndex:11]];
    if ([s hasPrefix:@"Create a session on "]) {
        return [NSString stringWithFormat:@"在 %@ 上创建会话", RXTranslate([s substringFromIndex:20])];
    }
    if ([s hasPrefix:@"Connection warning for "]) {
        return [NSString stringWithFormat:@"连接警告：%@", RXTranslate([s substringFromIndex:23])];
    }
    if ([s hasPrefix:@"登录 Tailscale、Access Rex securely from your other devices."]) return @"登录 Tailscale、从其他设备安全访问 Rex。";
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
    if ([s hasPrefix:@"录制 "] && [s hasSuffix:@" 的快捷键"]) {
        NSString *suffix = @" 的快捷键";
        NSString *action = [s substringWithRange:NSMakeRange(3, s.length - 3 - suffix.length)];
        return [NSString stringWithFormat:@"录制 %@ 的快捷键", RXTranslate(action)];
    }
    if ([s hasPrefix:@"Opens "] && [s hasSuffix:@" settings"]) {
        NSString *prefix = @"Opens ";
        NSString *suffix = @" settings";
        NSString *page = [s substringWithRange:NSMakeRange(prefix.length, s.length - prefix.length - suffix.length)];
        return [NSString stringWithFormat:@"打开“%@”设置", RXTranslate(page)];
    }
    if ([s hasPrefix:@"打开 "] && [s hasSuffix:@" settings"]) {
        NSString *prefix = @"打开 ";
        NSString *suffix = @" settings";
        NSString *page = [s substringWithRange:NSMakeRange(prefix.length, s.length - prefix.length - suffix.length)];
        return [NSString stringWithFormat:@"打开“%@”设置", RXTranslate(page)];
    }
    if ([s hasPrefix:@"Click to record a different shortcut."]) {
        return @"点击以录制其他快捷键。";
    }
    if ([s hasPrefix:@"Click to record a shortcut."]) {
        return @"点击以录制快捷键。";
    }
    if ([s containsString:@"Dock Badge"] || [s containsString:@"Sound"]) {
        s = [s stringByReplacingOccurrencesOfString:@"Dock Badge" withString:@"程序坞标记"];
        s = [s stringByReplacingOccurrencesOfString:@"Sound" withString:@"声音"];
        return s;
    }
    if ([s isEqualToString:@"Command Delete"]) return @"⌘ Delete";
    if ([s isEqualToString:@"Command Left Arrow"]) return @"⌘ ←";
    if ([s isEqualToString:@"Command Right Arrow"]) return @"⌘ →";
    if ([s isEqualToString:@"Option Left Arrow"]) return @"⌥ ←";
    if ([s isEqualToString:@"Option Right Arrow"]) return @"⌥ →";
    if ([s containsString:@"Option Command "]) {
        s = [s stringByReplacingOccurrencesOfString:@"Option" withString:@"⌥"];
        s = [s stringByReplacingOccurrencesOfString:@"Command" withString:@"⌘"];
        s = [s stringByReplacingOccurrencesOfString:@"Left Arrow" withString:@"←"];
        s = [s stringByReplacingOccurrencesOfString:@"Right Arrow" withString:@"→"];
        s = [s stringByReplacingOccurrencesOfString:@"Up Arrow" withString:@"↑"];
        s = [s stringByReplacingOccurrencesOfString:@"Down Arrow" withString:@"↓"];
        return s;
    }
    if ([s containsString:@"Command "] && ([s containsString:@"Arrow"] || [s containsString:@"Return"])) {
        s = [s stringByReplacingOccurrencesOfString:@"Command" withString:@"⌘"];
        s = [s stringByReplacingOccurrencesOfString:@"Left Arrow" withString:@"←"];
        s = [s stringByReplacingOccurrencesOfString:@"Right Arrow" withString:@"→"];
        s = [s stringByReplacingOccurrencesOfString:@"Up Arrow" withString:@"↑"];
        s = [s stringByReplacingOccurrencesOfString:@"Down Arrow" withString:@"↓"];
        s = [s stringByReplacingOccurrencesOfString:@"Return" withString:@"↩"];
        return s;
    }
    if ([s hasPrefix:@"Move "] && [s hasSuffix:@" pane"]) {
        NSString *middle = [s substringWithRange:NSMakeRange(5, s.length - 10)];
        return [NSString stringWithFormat:@"移动 %@ 窗格", middle];
    }
    return s;
}

static CFStringRef (*RXOriginalCFBundleCopyLocalizedString)(CFBundleRef, CFStringRef, CFStringRef, CFStringRef);
static CFStringRef (*RXOriginalCFBundleCopyLocalizedStringForLocalizations)(CFBundleRef, CFStringRef, CFStringRef, CFStringRef, CFArrayRef);
static CFAttributedStringRef (*RXOriginalCFAttributedStringCreate)(CFAllocatorRef, CFStringRef, CFDictionaryRef);
static void RXResolveCoreFoundation(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        RXOriginalCFBundleCopyLocalizedString = (CFStringRef (*)(CFBundleRef, CFStringRef, CFStringRef, CFStringRef))dlsym(RTLD_NEXT, "CFBundleCopyLocalizedString");
        RXOriginalCFBundleCopyLocalizedStringForLocalizations = (CFStringRef (*)(CFBundleRef, CFStringRef, CFStringRef, CFStringRef, CFArrayRef))dlsym(RTLD_NEXT, "CFBundleCopyLocalizedStringForLocalizations");
        RXOriginalCFAttributedStringCreate = (CFAttributedStringRef (*)(CFAllocatorRef, CFStringRef, CFDictionaryRef))dlsym(RTLD_NEXT, "CFAttributedStringCreate");
    });
}

CFAttributedStringRef CFAttributedStringCreate(CFAllocatorRef alloc, CFStringRef str, CFDictionaryRef attributes) {
    RXResolveCoreFoundation();
    NSString *source = (__bridge NSString *)str;
    NSString *translated = RXTranslate(source);
    CFStringRef input = translated.length && ![translated isEqualToString:source] ? (__bridge CFStringRef)translated : str;
    return RXOriginalCFAttributedStringCreate ? RXOriginalCFAttributedStringCreate(alloc, input, attributes) : NULL;
}

CFStringRef CFBundleCopyLocalizedString(CFBundleRef bundle, CFStringRef key, CFStringRef value, CFStringRef tableName) {
    RXResolveCoreFoundation();
    CFStringRef result = RXOriginalCFBundleCopyLocalizedString ? RXOriginalCFBundleCopyLocalizedString(bundle, key, value, tableName) : NULL;
    NSString *source = result ? (__bridge NSString *)result : (__bridge NSString *)(value ?: key);
    NSString *translated = RXTranslate(source);
    if (translated.length && ![translated isEqualToString:source]) {
        if (result) CFRelease(result);
        return CFStringCreateCopy(NULL, (__bridge CFStringRef)translated);
    }
    return result ?: CFStringCreateCopy(NULL, (__bridge CFStringRef)source);
}

CFStringRef CFBundleCopyLocalizedStringForLocalizations(CFBundleRef bundle, CFStringRef key, CFStringRef value, CFStringRef tableName, CFArrayRef localizations) {
    RXResolveCoreFoundation();
    CFStringRef result = RXOriginalCFBundleCopyLocalizedStringForLocalizations ? RXOriginalCFBundleCopyLocalizedStringForLocalizations(bundle, key, value, tableName, localizations) : NULL;
    NSString *source = result ? (__bridge NSString *)result : (__bridge NSString *)(value ?: key);
    NSString *translated = RXTranslate(source);
    if (translated.length && ![translated isEqualToString:source]) {
        if (result) CFRelease(result);
        return CFStringCreateCopy(NULL, (__bridge CFStringRef)translated);
    }
    return result ?: CFStringCreateCopy(NULL, (__bridge CFStringRef)source);
}

static NSAttributedString *RXTranslatedAttributedString(NSAttributedString *value) {
    if (![value isKindOfClass:[NSAttributedString class]]) return value;
    NSString *translated = RXTranslate(value.string);
    if (!translated.length || [translated isEqualToString:value.string]) return value;
    return [[NSAttributedString alloc] initWithString:translated attributes:[value attributesAtIndex:0 effectiveRange:NULL]];
}

static IMP origNSStringDrawAtPoint, origNSStringDrawInRect;
static IMP origAttributedDrawAtPoint, origAttributedDrawInRect, origAttributedDrawWithRect;
static IMP origAttributedStringGetter;


static CTLineRef (*RXOriginalCTLineCreateWithAttributedString)(CFAttributedStringRef);
static CTFramesetterRef (*RXOriginalCTFramesetterCreateWithAttributedString)(CFAttributedStringRef);
static CTTypesetterRef (*RXOriginalCTTypesetterCreateWithAttributedString)(CFAttributedStringRef);
static CTTypesetterRef (*RXOriginalCTTypesetterCreateWithAttributedStringAndOptions)(CFAttributedStringRef, CFDictionaryRef);
static void RXResolveCoreText(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        RXOriginalCTLineCreateWithAttributedString = (CTLineRef (*)(CFAttributedStringRef))dlsym(RTLD_NEXT, "CTLineCreateWithAttributedString");
        RXOriginalCTFramesetterCreateWithAttributedString = (CTFramesetterRef (*)(CFAttributedStringRef))dlsym(RTLD_NEXT, "CTFramesetterCreateWithAttributedString");
        RXOriginalCTTypesetterCreateWithAttributedString = (CTTypesetterRef (*)(CFAttributedStringRef))dlsym(RTLD_NEXT, "CTTypesetterCreateWithAttributedString");
        RXOriginalCTTypesetterCreateWithAttributedStringAndOptions = (CTTypesetterRef (*)(CFAttributedStringRef, CFDictionaryRef))dlsym(RTLD_NEXT, "CTTypesetterCreateWithAttributedStringAndOptions");
    });
}

CTLineRef CTLineCreateWithAttributedString(CFAttributedStringRef value) {
    RXResolveCoreText();
    NSAttributedString *translated = RXTranslatedAttributedString((__bridge NSAttributedString *)value);
    return RXOriginalCTLineCreateWithAttributedString ? RXOriginalCTLineCreateWithAttributedString((__bridge CFAttributedStringRef)translated) : NULL;
}

CTFramesetterRef CTFramesetterCreateWithAttributedString(CFAttributedStringRef value) {
    RXResolveCoreText();
    NSAttributedString *translated = RXTranslatedAttributedString((__bridge NSAttributedString *)value);
    return RXOriginalCTFramesetterCreateWithAttributedString ? RXOriginalCTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)translated) : NULL;
}

CTTypesetterRef CTTypesetterCreateWithAttributedString(CFAttributedStringRef value) {
    RXResolveCoreText();
    NSAttributedString *translated = RXTranslatedAttributedString((__bridge NSAttributedString *)value);
    return RXOriginalCTTypesetterCreateWithAttributedString ? RXOriginalCTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)translated) : NULL;
}

CTTypesetterRef CTTypesetterCreateWithAttributedStringAndOptions(CFAttributedStringRef value, CFDictionaryRef options) {
    RXResolveCoreText();
    NSAttributedString *translated = RXTranslatedAttributedString((__bridge NSAttributedString *)value);
    return RXOriginalCTTypesetterCreateWithAttributedStringAndOptions ? RXOriginalCTTypesetterCreateWithAttributedStringAndOptions((__bridge CFAttributedStringRef)translated, options) : NULL;
}

static void RXDebugTranslation(id self, SEL selector, NSString *value, NSString *source) {
    (void)self;
    (void)selector;
    (void)value;
    (void)source;
}

static IMP origTitle, origButtonTitleGetter, origMenuTitle, origMenuTitleGetter, origMenuAttributedTitle, origMenuAttributedTitleGetter, origMenuAccessibilityValue, origMenuAccessibilityLabel, origMenuAccessibilityTitle, origMenuAccessibilityDescription, origWindowTitle, origStringValue, origPlaceholder, origPlaceholderGetter, origAccessibilityLabel, origAccessibilityTitle, origAccessibilityHelp, origAccessibilityDescription, origToolTip, origAccessibilityValue, origSegmentAccessibilityValue, origSegmentAccessibilityDescription, origSegmentAccessibilityDescriptionAttribute, origToolbarViewerDescriptionAttribute, origToolbarViewerTitleAttribute, origPopupTitleOfSelectedItem, origPopupCellTitle, origViewAccessibilityLabelGetter, origViewAccessibilityTitleGetter, origViewAccessibilityHelpGetter, origViewAccessibilityDescriptionGetter, origViewAccessibilityPlaceholderGetter, origViewAccessibilityValueGetter, origViewAccessibilityValueDescriptionGetter, origViewAccessibilityRoleDescriptionGetter, origButtonAccessibilityLabel, origButtonAccessibilityTitle, origButtonAccessibilityHelp, origButtonAccessibilityDescription, origToolbarItemLabel, origToolbarItemLabelGetter, origToolbarItemPaletteLabel, origToolbarItemPaletteLabelGetter, origToolbarItemToolTip, origToolbarItemToolTipGetter, origBundleLocalized, origSplitChildren, origSplitters, origCellStringValue, origCellSetStringValue, origCellAccessibilityLabel, origCellAccessibilityTitle, origCellAccessibilityHelp, origCellAccessibilityValue, origSwiftLabel, origSwiftHelp, origSwiftDescription, origSwiftAttribute, origSwiftValue, origSwiftValueDescription, origSwiftRoleDescription, origSwiftPlaceholder, origSwiftAttributedLabel;
static IMP origAXElementAttribute, origAXElementValue, origAXElementPlaceholder, origAXElementLabel, origAXElementTitle, origAXElementHelp, origAXElementDescription, origAXElementRoleDescription;
static __thread BOOL RXInAXElementHook;
static NSMutableDictionary *RXPopupOriginals;
static NSMutableDictionary *RXMenuItemOriginals;
static NSWindow *RXAXWalkWindow;
static NSRect RXDefaultShellFrame;
static BOOL RXHasDefaultShellFrame;
static NSRect RXNotificationFrame;
static BOOL RXHasNotificationFrame;
static NSRect RXRemoteHeaderFrame;
static BOOL RXHasRemoteHeaderFrame;
static NSRect RXRemoteErrorFrame;
static BOOL RXHasRemoteErrorFrame;
static BOOL RXHasRemoteErrorNode;
static NSRect RXRemoteSaveFrame;
static BOOL RXHasRemoteSaveFrame;
static NSRect RXThemeEditorNameFrame;
static BOOL RXHasThemeEditorNameFrame;
// Residual overlays are attached to SwiftUI's private detail subtree. That
// subtree can be replaced while navigating settings, so keeping only a
// reference to the current detail view is not enough to remove an overlay
// created for the previous page. Track the views we create and remove those
// exact instances on the next refresh; native SwiftUI views are never touched.
static NSHashTable *RXOwnedResidualOverlays;
static void RXRefreshMenu(NSMenu *menu);
static void RXUpdateSettingsResidualOverlays(NSWindow *window);
static void RXTranslatePopupMenu(NSMenu *menu);
static void RXRefreshToolbarItem(NSToolbarItem *item);
static IMP RXPopupOriginal(id self, SEL sel) {
    for (Class cls = object_getClass(self); cls; cls = class_getSuperclass(cls)) {
        NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(sel)];
        NSValue *value = RXPopupOriginals[key];
        if (value) return value.pointerValue;
    }
    return NULL;
}

static id RXAXElementAttribute(id self, SEL _cmd, NSString *attribute) {
    id value = origAXElementAttribute ? ((id (*)(id, SEL, NSString *))origAXElementAttribute)(self, _cmd, attribute) : nil;
    if (RXInAXElementHook) return value;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"AX %@", attribute]);
    RXInAXElementHook = YES;
    id translated = [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
    RXInAXElementHook = NO;
    return translated;
}
static id RXAXElementObject(id self, SEL _cmd) {
    IMP original = (_cmd == @selector(accessibilityValue)) ? origAXElementValue : (_cmd == @selector(accessibilityPlaceholderValue) ? origAXElementPlaceholder : (_cmd == @selector(accessibilityLabel) ? origAXElementLabel : (_cmd == @selector(accessibilityTitle) ? origAXElementTitle : (_cmd == @selector(accessibilityHelp) ? origAXElementHelp : (_cmd == @selector(accessibilityDescription) ? origAXElementDescription : origAXElementRoleDescription)))));
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    if (RXInAXElementHook) return value;
    RXInAXElementHook = YES;
    id translated = [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
    RXInAXElementHook = NO;
    return translated;
}
static void RXSetTitle(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origTitle)(self, _cmd, RXTranslate(value));
}
static void RXSetToolbarItemLabel(id self, SEL _cmd, NSString *value) {
    if (origToolbarItemLabel) ((void (*)(id, SEL, NSString *))origToolbarItemLabel)(self, _cmd, RXTranslate(value));
}
static NSString *RXToolbarItemLabel(id self, SEL _cmd) {
    NSString *value = origToolbarItemLabelGetter ? ((NSString *(*)(id, SEL))origToolbarItemLabelGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetToolbarItemPaletteLabel(id self, SEL _cmd, NSString *value) {
    if (origToolbarItemPaletteLabel) ((void (*)(id, SEL, NSString *))origToolbarItemPaletteLabel)(self, _cmd, RXTranslate(value));
}
static NSString *RXToolbarItemPaletteLabel(id self, SEL _cmd) {
    NSString *value = origToolbarItemPaletteLabelGetter ? ((NSString *(*)(id, SEL))origToolbarItemPaletteLabelGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetToolbarItemToolTip(id self, SEL _cmd, NSString *value) {
    if (origToolbarItemToolTip) ((void (*)(id, SEL, NSString *))origToolbarItemToolTip)(self, _cmd, RXTranslate(value));
}
static NSString *RXToolbarItemToolTip(id self, SEL _cmd) {
    NSString *value = origToolbarItemToolTipGetter ? ((NSString *(*)(id, SEL))origToolbarItemToolTipGetter)(self, _cmd) : nil;
    return RXTranslate(value);
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
static NSString *RXMenuAccessibilityLabel(id self, SEL _cmd) {
    NSString *value = origMenuAccessibilityLabel ? ((NSString *(*)(id, SEL))origMenuAccessibilityLabel)(self, _cmd) : nil;
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
static NSString *RXSegmentAccessibilityDescriptionAttribute(id self, SEL _cmd) {
    NSString *value = origSegmentAccessibilityDescriptionAttribute ? ((NSString *(*)(id, SEL))origSegmentAccessibilityDescriptionAttribute)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXToolbarViewerDescriptionAttribute(id self, SEL _cmd) {
    NSString *value = origToolbarViewerDescriptionAttribute ? ((NSString *(*)(id, SEL))origToolbarViewerDescriptionAttribute)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXToolbarViewerTitleAttribute(id self, SEL _cmd) {
    NSString *value = origToolbarViewerTitleAttribute ? ((NSString *(*)(id, SEL))origToolbarViewerTitleAttribute)(self, _cmd) : nil;
    return RXTranslate(value);
}
static id RXSegmentAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    IMP original = origSegmentAccessibilityValue ? origSegmentAccessibilityValue : (origAXElementAttribute ? origAXElementAttribute : origAccessibilityValue);
    id value = original ? ((id (*)(id, SEL, NSString *))original)(self, _cmd, attribute) : nil;
    NSString *translatedValue = [value isKindOfClass:[NSString class]] ? RXTranslate(value) : nil;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"Segment %@", attribute]);
    if ([value isKindOfClass:[NSString class]] &&
        ([attribute isEqualToString:NSAccessibilityTitleAttribute] ||
         [attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityHelpAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute])) {
        return translatedValue;
    }
    return value;
}
static NSString *RXCellStringValue(id self, SEL _cmd) {
    NSString *value = origCellStringValue ? ((NSString *(*)(id, SEL))origCellStringValue)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXCellSetStringValue(id self, SEL _cmd, NSString *value) {
    if (origCellSetStringValue) ((void (*)(id, SEL, NSString *))origCellSetStringValue)(self, _cmd, RXTranslate(value));
}
static NSString *RXPopupTitleOfSelectedItem(id self, SEL _cmd) {
    IMP original = RXPopupOriginal(self, _cmd);
    if (!original) original = origPopupTitleOfSelectedItem;
    NSString *value = original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Popup selected");
    return RXTranslate(value);
}
static NSString *RXPopupCellTitle(id self, SEL _cmd) {
    IMP original = RXPopupOriginal(self, _cmd);
    if (!original) original = origPopupCellTitle;
    NSString *value = original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Popup title");
    return RXTranslate(value);
}
static id RXPopupAccessibilityValue(id self, SEL _cmd) {
    IMP original = RXPopupOriginal(self, _cmd);
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Popup value");
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXPopupAccessibilityValueAttribute(id self, SEL _cmd) {
    IMP original = RXPopupOriginal(self, _cmd);
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Popup attribute");
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static void RXSetWindowTitle(id self, SEL _cmd, NSString *value) {
    if (origWindowTitle) ((void (*)(id, SEL, NSString *))origWindowTitle)(self, _cmd, RXTranslate(value));
    // Settings navigation changes the window title before SwiftUI finishes
    // replacing its detail subtree. Refresh immediately so an overlay from
    // the previous page cannot remain visible during that transition.
    if ([self isKindOfClass:[NSWindow class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RXUpdateSettingsResidualOverlays((NSWindow *)self);
        });
    }
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
static void RXSetAccessibilityDescription(id self, SEL _cmd, NSString *value) {
    if (origAccessibilityDescription) ((void (*)(id, SEL, NSString *))origAccessibilityDescription)(self, _cmd, RXTranslate(value));
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
static NSString *RXViewAccessibilityDescription(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityDescriptionGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityDescriptionGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static NSString *RXViewAccessibilityPlaceholder(id self, SEL _cmd) {
    NSString *value = origViewAccessibilityPlaceholderGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityPlaceholderGetter)(self, _cmd) : nil;
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
static NSString *RXButtonAccessibilityDescription(id self, SEL _cmd) {
    NSString *value = origButtonAccessibilityDescription ? ((NSString *(*)(id, SEL))origButtonAccessibilityDescription)(self, _cmd) : nil;
    return RXTranslate(value);
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
static NSMutableDictionary *RXSwiftNodeOriginals;
static IMP RXSwiftNodeOriginal(id self, SEL sel) {
    for (Class cls = object_getClass(self); cls; cls = class_getSuperclass(cls)) {
        NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(sel)];
        NSValue *value = RXSwiftNodeOriginals[key];
        if (value) return value.pointerValue;
    }
    return NULL;
}
static NSString *RXSwiftLabel(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftLabel;
    return RXTranslate(original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil);
}
static NSString *RXSwiftHelp(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftHelp;
    return RXTranslate(original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil);
}
static NSString *RXSwiftDescription(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftDescription;
    return RXTranslate(original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil);
}
static NSString *RXSwiftPlaceholder(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftPlaceholder;
    return RXTranslate(original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil);
}
static id RXSwiftAttribute(id self, SEL _cmd, NSString *attribute) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftAttribute;
    id value = original ? ((id (*)(id, SEL, NSString *))original)(self, _cmd, attribute) : nil;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"Swift %@", attribute]);
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftValue(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftValue;
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Swift value");
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftValueDescription(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftValueDescription;
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static id RXSwiftRoleDescription(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftRoleDescription;
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    return [value isKindOfClass:[NSString class]] ? RXTranslate(value) : value;
}
static NSAttributedString *RXSwiftAttributedLabel(id self, SEL _cmd) {
    IMP original = RXSwiftNodeOriginal(self, _cmd);
    if (!original) original = origSwiftAttributedLabel;
    NSAttributedString *value = original ? ((NSAttributedString *(*)(id, SEL))original)(self, _cmd) : nil;
    return value ? [[NSAttributedString alloc] initWithString:RXTranslate(value.string)] : nil;
}

static BOOL RXIsSwiftAccessibilityNode(Class cls, Class nodeClass) {
    for (Class current = cls; current; current = class_getSuperclass(current)) {
        if (current == nodeClass) return YES;
    }
    return NO;
}

static void RXInstallSwiftNodeHooks(void) {
    Class nodeClass = objc_getClass("SwiftUI.AccessibilityNode");
    if (!nodeClass) return;
    if (!RXSwiftNodeOriginals) RXSwiftNodeOriginals = [NSMutableDictionary dictionary];
    SEL selectors[] = {
        @selector(accessibilityLabel), @selector(accessibilityHelp), @selector(accessibilityDescription),
        @selector(accessibilityPlaceholderValue), @selector(accessibilityAttributeValue:),
        @selector(accessibilityValue), @selector(accessibilityValueDescription), @selector(accessibilityRoleDescription),
        @selector(accessibilityAttributedLabel)
    };
    IMP replacements[] = {
        (IMP)RXSwiftLabel, (IMP)RXSwiftHelp, (IMP)RXSwiftDescription, (IMP)RXSwiftPlaceholder,
        (IMP)RXSwiftAttribute, (IMP)RXSwiftValue,
        (IMP)RXSwiftValueDescription, (IMP)RXSwiftRoleDescription, (IMP)RXSwiftAttributedLabel
    };
    unsigned int count = objc_getClassList(NULL, 0);
    Class *classes = (Class *)calloc(count, sizeof(Class));
    objc_getClassList(classes, count);
    for (unsigned int i = 0; i < count; i++) {
        Class cls = classes[i];
        if (!RXIsSwiftAccessibilityNode(cls, nodeClass)) continue;
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(cls, &methodCount);
        for (NSUInteger j = 0; j < sizeof(selectors) / sizeof(selectors[0]); j++) {
            for (unsigned int k = 0; k < methodCount; k++) {
                if (method_getName(methods[k]) != selectors[j]) continue;
                NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(selectors[j])];
                if (!RXSwiftNodeOriginals[key]) {
                    RXSwiftNodeOriginals[key] = [NSValue valueWithPointer:method_getImplementation(methods[k])];
                    method_setImplementation(methods[k], replacements[j]);
                }
                break;
            }
        }
        free(methods);
    }
    Class cellValueClass = [NSPopUpButtonCell class];
    SEL cellValueSelector = @selector(accessibilityValue);
    NSString *cellValueKey = [NSString stringWithFormat:@"%p:%s", cellValueClass, sel_getName(cellValueSelector)];
    if (!RXPopupOriginals[cellValueKey]) {
        Method inherited = class_getInstanceMethod(cellValueClass, cellValueSelector);
        BOOL hasOwnMethod = NO;
        unsigned int ownMethodCount = 0;
        Method *ownMethods = class_copyMethodList(cellValueClass, &ownMethodCount);
        for (unsigned int i = 0; i < ownMethodCount; i++) {
            if (method_getName(ownMethods[i]) == cellValueSelector) {
                hasOwnMethod = YES;
                break;
            }
        }
        free(ownMethods);
        if (inherited && !hasOwnMethod) {
            class_addMethod(cellValueClass, cellValueSelector, method_getImplementation(inherited), method_getTypeEncoding(inherited));
        }
        Method method = class_getInstanceMethod(cellValueClass, cellValueSelector);
        if (method) {
            RXPopupOriginals[cellValueKey] = [NSValue valueWithPointer:method_getImplementation(method)];
            method_setImplementation(method, (IMP)RXPopupAccessibilityValue);
        }
    }
    free(classes);
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
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"View %@", attribute]);
    if ([value isKindOfClass:[NSString class]] && ([attribute isEqualToString:NSAccessibilityTitleAttribute] || [attribute isEqualToString:NSAccessibilityDescriptionAttribute] || [attribute isEqualToString:NSAccessibilityHelpAttribute] || [attribute isEqualToString:NSAccessibilityValueAttribute] || [attribute isEqualToString:NSAccessibilityPlaceholderValueAttribute] || [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] || [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute])) {
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

static id RXRawAXValue(id element, NSString *attribute);
static IMP origTextFieldTextViewDraw, origNSTextViewDraw, origNSTextViewSetString;

static void RXDrawTranslatedTextViewContent(NSTextView *textView) {
    NSString *raw = textView.string ?: @"";
    NSString *translated = RXTranslate(raw);
    if (!translated.length || [translated isEqualToString:raw]) return;
    [NSColor.controlBackgroundColor setFill];
    NSRectFill(textView.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: textView.font ?: [NSFont systemFontOfSize:16.0],
        NSForegroundColorAttributeName: textView.textColor ?: NSColor.labelColor
    };
    [translated drawAtPoint:NSMakePoint(NSMinX(textView.bounds) + 1.0, NSMinY(textView.bounds) - 1.0) withAttributes:attributes];
}

static void RXNSTextViewDraw(id self, SEL _cmd, NSRect rect) {
    if (origNSTextViewDraw) ((void (*)(id, SEL, NSRect))origNSTextViewDraw)(self, _cmd, rect);
    if ([self isKindOfClass:[NSTextView class]]) RXDrawTranslatedTextViewContent((NSTextView *)self);
}

static void RXNSTextViewSetString(id self, SEL _cmd, NSString *value) {
    if (origNSTextViewSetString) ((void (*)(id, SEL, NSString *))origNSTextViewSetString)(self, _cmd, RXTranslate(value));
}

static void RXTextFieldTextViewDraw(id self, SEL _cmd, NSRect rect) {
    if (origTextFieldTextViewDraw) ((void (*)(id, SEL, NSRect))origTextFieldTextViewDraw)(self, _cmd, rect);
    NSString *raw = nil;
    if ([self isKindOfClass:[NSTextView class]]) raw = [(NSTextView *)self string];
    if (!raw.length) {
        id value = RXRawAXValue(self, NSAccessibilityValueAttribute);
        if ([value isKindOfClass:[NSString class]]) raw = value;
    }
    NSString *translated = RXTranslate(raw);
    if (!translated.length || [translated isEqualToString:raw]) return;
    NSView *view = (NSView *)self;
    [NSColor.controlBackgroundColor setFill];
    NSRectFill(view.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:16.0],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    [translated drawAtPoint:NSMakePoint(NSMinX(view.bounds), NSMinY(view.bounds) - 1.0) withAttributes:attributes];
}

static void RXInstallTextFieldTextViewHook(void) {
    Class cls = objc_getClass("RexMacOS.RexTextFieldTextView");
    if (!cls || origTextFieldTextViewDraw) return;
    SEL selector = @selector(drawRect:);
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    Method ownMethod = NULL;
    for (unsigned int i = 0; i < methodCount; i++) {
        if (method_getName(methods[i]) == selector) {
            ownMethod = methods[i];
            break;
        }
    }
    free(methods);
    if (!ownMethod) return;
    origTextFieldTextViewDraw = method_getImplementation(ownMethod);
    method_setImplementation(ownMethod, (IMP)RXTextFieldTextViewDraw);
}

static void RXAttributedDrawWithRect(id self, SEL _cmd, NSRect rect, NSStringDrawingOptions options, NSStringDrawingContext *context) {
    NSAttributedString *translated = RXTranslatedAttributedString(self);
    if (origAttributedDrawWithRect) ((void (*)(id, SEL, NSRect, NSStringDrawingOptions, NSStringDrawingContext *))origAttributedDrawWithRect)(translated, _cmd, rect, options, context);
}

static void RXNSStringDrawAtPoint(id self, SEL _cmd, NSPoint point, NSDictionary *attributes) {
    NSString *translated = RXTranslate(self);
    if (origNSStringDrawAtPoint) ((void (*)(id, SEL, NSPoint, NSDictionary *))origNSStringDrawAtPoint)(translated, _cmd, point, attributes);
}

static void RXNSStringDrawInRect(id self, SEL _cmd, NSRect rect, NSDictionary *attributes) {
    NSString *translated = RXTranslate(self);
    if (origNSStringDrawInRect) ((void (*)(id, SEL, NSRect, NSDictionary *))origNSStringDrawInRect)(translated, _cmd, rect, attributes);
}

static void RXAttributedDrawAtPoint(id self, SEL _cmd, NSPoint point) {
    NSAttributedString *translated = RXTranslatedAttributedString(self);
    if (origAttributedDrawAtPoint) ((void (*)(id, SEL, NSPoint))origAttributedDrawAtPoint)(translated, _cmd, point);
}

static void RXAttributedDrawInRect(id self, SEL _cmd, NSRect rect) {
    NSAttributedString *translated = RXTranslatedAttributedString(self);
    if (origAttributedDrawInRect) ((void (*)(id, SEL, NSRect))origAttributedDrawInRect)(translated, _cmd, rect);
}

static NSString *RXAttributedStringGetter(id self, SEL _cmd) {
    NSString *value = origAttributedStringGetter ? ((NSString *(*)(id, SEL))origAttributedStringGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}

static void RXInstallDrawingHooks(void) {
    origNSStringDrawAtPoint = RXHook([NSString class], @selector(drawAtPoint:withAttributes:), (IMP)RXNSStringDrawAtPoint);
    origNSStringDrawInRect = RXHook([NSString class], @selector(drawInRect:withAttributes:), (IMP)RXNSStringDrawInRect);
    origAttributedDrawAtPoint = RXHook([NSAttributedString class], @selector(drawAtPoint:), (IMP)RXAttributedDrawAtPoint);
    origAttributedDrawInRect = RXHook([NSAttributedString class], @selector(drawInRect:), (IMP)RXAttributedDrawInRect);
    origAttributedDrawWithRect = RXHook([NSAttributedString class], @selector(drawWithRect:options:context:), (IMP)RXAttributedDrawWithRect);
    origAttributedStringGetter = RXHook([NSAttributedString class], @selector(string), (IMP)RXAttributedStringGetter);
}

/* Rex renders the command palette in two private NSView subclasses, bypassing
   SwiftUI Text and AppKit text controls. Keep this hook limited to those views. */
static IMP origCommandPaletteListDraw, origCommandPaletteContentDraw;

static NSString *RXPaletteTextInTree(NSView *view) {
    if ([view isKindOfClass:[NSTextView class]]) return ((NSTextView *)view).string ?: @"";
    for (NSView *child in view.subviews) {
        NSString *query = RXPaletteTextInTree(child);
        if (query != nil) return query;
    }
    return nil;
}

static NSString *RXPaletteQuery(NSView *view) {
    for (NSView *ancestor = view; ancestor; ancestor = ancestor.superview) {
        NSString *query = RXPaletteTextInTree(ancestor);
        if (query != nil) return query;
    }
    return nil;
}

static NSArray *RXPaletteCommands(void) {
    static NSArray *commands;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        commands = @[
            @"Change Session…", @"Rename Session", @"Rename Tab", @"Add Remote Host…",
            @"New Session", @"New Tab", @"Go to Directory…", @"New Window",
            @"Move Tab to New Window", @"Close Tab", @"Refresh Sessions", @"Close Session",
            @"Close Window", @"Enter Full Screen", @"Pane", @"Split Right", @"Split Down",
            @"Split Left", @"Split Up", @"Split Best Fit", @"Focus Left", @"Focus Right",
            @"Focus Up", @"Focus Down", @"Focus Previous Pane", @"Focus Next Pane",
            @"Move Pane Left", @"Move Pane Right", @"Move Pane Up", @"Move Pane Down",
            @"Balance Splits", @"Resize Pane", @"Move Pane to Tab…", @"Copy Pane ID",
            @"Send Key", @"Send Key to Server", @"Jump to Previous Prompt", @"Jump to Next Prompt",
            @"Clear Terminal", @"Reset Terminal", @"Enter Mode", @"Exit Mode", @"Exit All Modes",
            @"Toggle Tab Style", @"Import Theme File", @"Switch Appearance Mode",
            @"Copy Config File Path", @"Reload Config", @"View", @"Color Scheme", @"Tab Style",
            @"Reset Font Size", @"Increase Font Size", @"Decrease Font Size", @"Toggle Sidebar",
            @"Toggle Activity", @"Show Activity", @"Show Previous Tab", @"Show Next Tab",
            @"Move Tab Backward", @"Move Tab Forward", @"Previous Session", @"Next Session"
        ];
    });
    return commands;
}

static NSArray *RXPaletteRowsForQuery(NSString *query) {
    NSArray *commands = RXPaletteCommands();
    if (query.length == 0) return commands;
    NSString *needle = query.lowercaseString;
    if ([needle isEqualToString:@"tab"]) {
        return @[
            @"Commands", @"Tabs Above", @"Tabs on Left Side", @"Tabs on Right Side",
            @"New Tab", @"Close Tab", @"Rename Tab", @"Move Tab to New Window",
            @"Go to Directory…", @"Comfortable Pane Style", @"Tabs", @"", @"Pane",
            @"Split Pane Best Fit"
        ];
    }
    if ([needle isEqualToString:@"settings"]) {
        return @[@"Settings…", @"Grant System Permissions…", @"Copy Config File Path", @"Reload Config"];
    }
    NSMutableArray *rows = [NSMutableArray array];
    for (NSString *command in commands) {
        if ([command isEqualToString:@"Pane"]) continue;
        NSString *translated = RXTranslate(command);
        if ([command.lowercaseString containsString:needle] || [translated.lowercaseString containsString:needle]) [rows addObject:command];
    }
    return rows;
}

static void RXDrawPaletteText(NSString *text, NSRect rect, BOOL selected) {
    NSColor *background = selected ? NSColor.selectedControlColor : NSColor.windowBackgroundColor;
    [background setFill];
    NSRectFill(rect);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:selected ? 16.0 : 16.0],
        NSForegroundColorAttributeName: selected ? NSColor.alternateSelectedControlTextColor : NSColor.labelColor
    };
    [RXTranslate(text) drawAtPoint:NSMakePoint(NSMinX(rect) + 8.0, NSMinY(rect) + 5.0) withAttributes:attributes];
}

static void RXCommandPaletteListDraw(id self, SEL _cmd, NSRect rect) {
    if (origCommandPaletteListDraw) ((void (*)(id, SEL, NSRect))origCommandPaletteListDraw)(self, _cmd, rect);
    NSView *view = (NSView *)self;
    NSString *query = RXPaletteQuery(view) ?: @"";
    NSArray *rows = RXPaletteRowsForQuery(query);
    // Clear Rex's custom-drawn labels before repainting translated rows.
    NSRect textColumn = NSMakeRect(NSMinX(rect), NSMinY(rect), MIN(260.0, NSWidth(rect)), NSHeight(rect));
    [NSColor.windowBackgroundColor setFill];
    NSRectFill(textColumn);
    CGFloat rowHeight = 28.5;
    CGFloat originY = view.bounds.origin.y;
    for (NSUInteger index = 0; index < rows.count; index++) {
        CGFloat y = index * rowHeight - originY;
        if (y + rowHeight < 0 || y > NSMaxY(rect)) continue;
        NSUInteger selectedIndex = [query.lowercaseString isEqualToString:@"tab"] ? 1 : 0;
        BOOL selected = index == selectedIndex;
        NSRect textRect = NSMakeRect(10.0, y + 1.0, MIN(250.0, view.bounds.size.width - 20.0), rowHeight - 2.0);
        RXDrawPaletteText(rows[index], textRect, selected);
    }
}

static void RXCommandPaletteContentDraw(id self, SEL _cmd, NSRect rect) {
    if (origCommandPaletteContentDraw) ((void (*)(id, SEL, NSRect))origCommandPaletteContentDraw)(self, _cmd, rect);
    NSView *view = (NSView *)self;
    NSString *query = RXPaletteQuery(view) ?: @"";
    if (query.length == 0) {
        NSRect placeholderRect = NSMakeRect(32.0, 9.0, MAX(0.0, view.bounds.size.width - 42.0), 34.0);
        [NSColor.controlBackgroundColor setFill];
        NSRectFill(placeholderRect);
        NSDictionary *attributes = @{NSFontAttributeName: [NSFont systemFontOfSize: 16.0], NSForegroundColorAttributeName: NSColor.secondaryLabelColor};
        [@"搜索命令、会话和标签页…" drawAtPoint:NSMakePoint(placeholderRect.origin.x + 5.0, placeholderRect.origin.y + 8.0) withAttributes:attributes];
    }
    NSRect footer = NSMakeRect(92.0, view.bounds.size.height - 36.0, 210.0, 28.0);
    [NSColor.windowBackgroundColor setFill];
    NSRectFill(footer);
    NSDictionary *footerAttributes = @{NSFontAttributeName: [NSFont systemFontOfSize: 13.0], NSForegroundColorAttributeName: NSColor.secondaryLabelColor};
    [@"更改快捷键" drawAtPoint:NSMakePoint(footer.origin.x + 4.0, footer.origin.y + 6.0) withAttributes:footerAttributes];
    [@"操作" drawAtPoint:NSMakePoint(footer.origin.x + 150.0, footer.origin.y + 6.0) withAttributes:footerAttributes];
}

static void RXInstallCommandPaletteHooks(void) {
    Class listClass = objc_getClass("_TtCE8RexMacOSO9RexShared9Workspace22CommandPaletteListView");
    Class contentClass = objc_getClass("_TtCE8RexMacOSO9RexShared9Workspace25CommandPaletteContentView");
    if (listClass && !origCommandPaletteListDraw) origCommandPaletteListDraw = RXHook(listClass, @selector(drawRect:), (IMP)RXCommandPaletteListDraw);
    if (contentClass && !origCommandPaletteContentDraw) origCommandPaletteContentDraw = RXHook(contentClass, @selector(drawRect:), (IMP)RXCommandPaletteContentDraw);
}

static NSString *RXPopupTitleOfSelectedItem(id self, SEL _cmd);
static NSString *RXPopupCellTitle(id self, SEL _cmd);
static BOOL RXIsSubclassOf(Class cls, Class parent) {
    for (Class current = cls; current; current = class_getSuperclass(current)) if (current == parent) return YES;
    return NO;
}

static IMP RXMenuItemOriginal(id self, SEL sel) {
    for (Class cls = object_getClass(self); cls; cls = class_getSuperclass(cls)) {
        NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(sel)];
        NSValue *value = RXMenuItemOriginals[key];
        if (value) return value.pointerValue;
    }
    return NULL;
}

static NSString *RXMenuItemTitle(id self, SEL _cmd) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    NSString *value = original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil;
    return RXTranslate(value);
}

static void RXMenuItemSetTitle(id self, SEL _cmd, NSString *value) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    if (original) ((void (*)(id, SEL, NSString *))original)(self, _cmd, RXTranslate(value));
}

static NSAttributedString *RXMenuItemAttributedTitle(id self, SEL _cmd) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    NSAttributedString *value = original ? ((NSAttributedString *(*)(id, SEL))original)(self, _cmd) : nil;
    if (!value) return nil;
    NSString *translated = RXTranslate(value.string);
    return [translated isEqualToString:value.string] ? value : [[NSAttributedString alloc] initWithString:translated attributes:[value attributesAtIndex:0 effectiveRange:NULL]];
}

static void RXMenuItemSetAttributedTitle(id self, SEL _cmd, NSAttributedString *value) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    if (!original) return;
    NSString *translated = RXTranslate(value.string);
    if (translated && ![translated isEqualToString:value.string]) {
        value = [[NSAttributedString alloc] initWithString:translated attributes:[value attributesAtIndex:0 effectiveRange:NULL]];
    }
    ((void (*)(id, SEL, NSAttributedString *))original)(self, _cmd, value);
}

static id RXMenuItemAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    id value = original ? ((id (*)(id, SEL, NSString *))original)(self, _cmd, attribute) : nil;
    if ([value isKindOfClass:[NSString class]]) return RXTranslate(value);
    return value;
}

static NSString *RXMenuItemAccessibilityText(id self, SEL _cmd) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    NSString *value = original ? ((NSString *(*)(id, SEL))original)(self, _cmd) : nil;
    return RXTranslate(value);
}

static id RXMenuItemAccessibilityObject(id self, SEL _cmd) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    id value = original ? ((id (*)(id, SEL))original)(self, _cmd) : nil;
    if ([value isKindOfClass:[NSString class]]) return RXTranslate(value);
    if ([value isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attributed = value;
        NSString *translated = RXTranslate(attributed.string);
        return [translated isEqualToString:attributed.string] ? value : [[NSAttributedString alloc] initWithString:translated attributes:[attributed attributesAtIndex:0 effectiveRange:NULL]];
    }
    return value;
}

static void RXMenuNeedsUpdate(id self, SEL _cmd, NSMenu *menu) {
    IMP original = RXMenuItemOriginal(self, _cmd);
    if (original) ((void (*)(id, SEL, NSMenu *))original)(self, _cmd, menu);
    RXRefreshMenu(menu);
}

static IMP RXMenuItemInheritedOriginal(SEL sel) {
    if (sel == @selector(title)) return origMenuTitleGetter;
    if (sel == @selector(setTitle:)) return origMenuTitle;
    if (sel == @selector(attributedTitle)) return origMenuAttributedTitleGetter;
    if (sel == @selector(setAttributedTitle:)) return origMenuAttributedTitle;
    if (sel == @selector(accessibilityAttributeValue:)) return origMenuAccessibilityValue;
    if (sel == @selector(accessibilityLabel)) return origMenuAccessibilityLabel;
    if (sel == @selector(accessibilityTitle)) return origMenuAccessibilityTitle;
    if (sel == @selector(accessibilityDescription)) return origMenuAccessibilityDescription;
    if (sel == @selector(accessibilityHelp)) return origAXElementHelp;
    if (sel == @selector(accessibilityValue)) return origAXElementValue;
    if (sel == @selector(accessibilityValueDescription)) return origSwiftValueDescription;
    if (sel == @selector(accessibilityRoleDescription)) return origSwiftRoleDescription;
    if (sel == @selector(accessibilityAttributedLabel)) return origSwiftAttributedLabel;
    return NULL;
}

static void RXInstallMenuItemHooks(void) {
    if (!RXMenuItemOriginals) RXMenuItemOriginals = [NSMutableDictionary dictionary];
    SEL selectors[] = {
        @selector(accessibilityAttributeValue:), @selector(accessibilityLabel), @selector(accessibilityTitle),
        @selector(accessibilityDescription), @selector(accessibilityHelp), @selector(accessibilityValue),
        @selector(accessibilityValueDescription), @selector(accessibilityRoleDescription), @selector(accessibilityAttributedLabel),
        @selector(menuNeedsUpdate:)
    };
    IMP replacements[] = {
        (IMP)RXMenuItemAccessibilityAttributeValue, (IMP)RXMenuItemAccessibilityText, (IMP)RXMenuItemAccessibilityText,
        (IMP)RXMenuItemAccessibilityText, (IMP)RXMenuItemAccessibilityText, (IMP)RXMenuItemAccessibilityObject,
        (IMP)RXMenuItemAccessibilityText, (IMP)RXMenuItemAccessibilityText, (IMP)RXMenuItemAccessibilityObject,
        (IMP)RXMenuNeedsUpdate
    };
    unsigned int count = objc_getClassList(NULL, 0);
    Class *classes = (Class *)calloc(count, sizeof(Class));
    objc_getClassList(classes, count);
    for (unsigned int i = 0; i < count; i++) {
        Class cls = classes[i];
        const char *className = class_getName(cls);
        BOOL swiftMenuItem = strstr(className, "SwiftUI.SwiftUIMenuItem") != NULL || strstr(className, "SwiftUI.AppKitMainMenuItem") != NULL;
        if (!swiftMenuItem) continue;
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(cls, &methodCount);
        for (NSUInteger j = 0; j < sizeof(selectors) / sizeof(selectors[0]); j++) {
            if (swiftMenuItem) {
                BOOL hasOwnMethod = NO;
                for (unsigned int k = 0; k < methodCount; k++) {
                    if (method_getName(methods[k]) == selectors[j]) {
                        hasOwnMethod = YES;
                        break;
                    }
                }
                if (!hasOwnMethod) {
                    Method inherited = class_getInstanceMethod(cls, selectors[j]);
                    IMP inheritedImplementation = RXMenuItemInheritedOriginal(selectors[j]);
                    if (!inheritedImplementation && inherited) {
                        inheritedImplementation = method_getImplementation(inherited);
                        if (inheritedImplementation == replacements[j]) inheritedImplementation = NULL;
                    }
                    if (inherited && inheritedImplementation) {
                        class_addMethod(cls, selectors[j], inheritedImplementation, method_getTypeEncoding(inherited));
                        free(methods);
                        methods = class_copyMethodList(cls, &methodCount);
                    }
                }
            }
            for (unsigned int k = 0; k < methodCount; k++) {
                if (method_getName(methods[k]) != selectors[j]) continue;
                NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(selectors[j])];
                if (!RXMenuItemOriginals[key]) {
                    RXMenuItemOriginals[key] = [NSValue valueWithPointer:method_getImplementation(methods[k])];
                    method_setImplementation(methods[k], replacements[j]);
                }
                break;
            }
        }
        free(methods);
    }
    free(classes);
}
static void RXInstallPopupHooks(void) {
    Class popup = [NSPopUpButton class];
    Class popupCell = [NSPopUpButtonCell class];
    if (!RXPopupOriginals) RXPopupOriginals = [NSMutableDictionary dictionary];
    unsigned int count = objc_getClassList(NULL, 0);
    Class *classes = (Class *)calloc(count, sizeof(Class));
    objc_getClassList(classes, count);
    for (unsigned int i = 0; i < count; i++) {
        Class cls = classes[i];
        SEL selectors[4];
        IMP replacements[4];
        NSUInteger selectorCount = 0;
        if (RXIsSubclassOf(cls, popup)) {
            selectors[selectorCount] = @selector(titleOfSelectedItem);
            replacements[selectorCount++] = (IMP)RXPopupTitleOfSelectedItem;
            selectors[selectorCount] = @selector(accessibilityValue);
            replacements[selectorCount++] = (IMP)RXPopupAccessibilityValue;
        }
        if (RXIsSubclassOf(cls, popupCell)) {
            selectors[selectorCount] = @selector(title);
            replacements[selectorCount++] = (IMP)RXPopupCellTitle;
            selectors[selectorCount] = @selector(accessibilityValueAttribute);
            replacements[selectorCount++] = (IMP)RXPopupAccessibilityValueAttribute;
        }
        for (NSUInteger j = 0; j < selectorCount; j++) {
            SEL sel = selectors[j];
            IMP replacement = replacements[j];
            unsigned int methodCount = 0;
            Method *methods = class_copyMethodList(cls, &methodCount);
            Method ownMethod = NULL;
            for (unsigned int k = 0; k < methodCount; k++) {
                if (method_getName(methods[k]) == sel) {
                    ownMethod = methods[k];
                    break;
                }
            }
            free(methods);
            if (!ownMethod) {
                Method inherited = class_getInstanceMethod(cls, sel);
                IMP inheritedImplementation = inherited ? method_getImplementation(inherited) : NULL;
                if (!inherited || inheritedImplementation == replacement) continue;
                class_addMethod(cls, sel, inheritedImplementation, method_getTypeEncoding(inherited));
                ownMethod = class_getInstanceMethod(cls, sel);
            }
            if (!ownMethod || method_getImplementation(ownMethod) == replacement) continue;
            NSString *key = [NSString stringWithFormat:@"%p:%s", cls, sel_getName(sel)];
            if (!RXPopupOriginals[key]) {
                RXPopupOriginals[key] = [NSValue valueWithPointer:method_getImplementation(ownMethod)];
                method_setImplementation(ownMethod, replacement);
            }
        }
    }
    free(classes);
}
static void RXRefreshMenu(NSMenu *menu) {
    if (![menu isKindOfClass:[NSMenu class]]) return;
    for (NSMenuItem *item in menu.itemArray) {
        NSString *title = item.title;
        NSString *translated = RXTranslate(title);
        if (translated.length && ![translated isEqualToString:title]) [item setTitle:translated];
        if (translated.length && [item respondsToSelector:@selector(setAccessibilityLabel:)]) item.accessibilityLabel = translated;
        if (translated.length && [item respondsToSelector:@selector(setAccessibilityTitle:)]) item.accessibilityTitle = translated;
        if (translated.length && [item respondsToSelector:@selector(accessibilitySetValue:forAttribute:)]) [item accessibilitySetValue:translated forAttribute:NSAccessibilityTitleAttribute];
        NSAttributedString *attributed = item.attributedTitle;
        NSString *attributedText = RXTranslate(attributed.string);
        if (attributedText.length && ![attributedText isEqualToString:attributed.string]) {
            [item setAttributedTitle:[[NSAttributedString alloc] initWithString:attributedText attributes:[attributed attributesAtIndex:0 effectiveRange:NULL]]];
        }
        RXRefreshMenu(item.submenu);
    }
}

static void RXTranslatePopupMenu(NSMenu *menu) {
    if (![menu isKindOfClass:[NSMenu class]]) return;
    for (NSMenuItem *item in menu.itemArray) {
        NSString *translated = RXTranslate(item.title);
        if (translated.length && ![translated isEqualToString:item.title]) [item setTitle:translated];
        RXTranslatePopupMenu(item.submenu);
    }
}

static void RXWalkAX(id element, NSUInteger depth);

// Runtime overlays are implementation views owned by this patch. They are
// deliberately non-interactive and must not be sent through Rex's recursive
// accessibility walk: AppKit can ask an overlay for its children while the
// walk is already servicing the same attribute, which re-enters the hook.
static BOOL RXIsOwnedOverlayObject(id object) {
    if (!object) return NO;
    Class cls = object_getClass(object);
    const char *name = cls ? class_getName(cls) : NULL;
    return name && strncmp(name, "RX", 2) == 0;
}

static id RXRawAXValue(id element, NSString *attribute) {
    if ([element isKindOfClass:[NSView class]] && origAccessibilityValue) {
        return ((id (*)(id, SEL, NSString *))origAccessibilityValue)(element, @selector(accessibilityAttributeValue:), attribute);
    }
    if (origAXElementAttribute && [element respondsToSelector:@selector(accessibilityAttributeValue:)]) {
        return ((id (*)(id, SEL, NSString *))origAXElementAttribute)(element, @selector(accessibilityAttributeValue:), attribute);
    }
    return nil;
}

static void RXWalk(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return;
    if (RXIsOwnedOverlayObject(view)) return;
    if ([view isKindOfClass:[NSTextField class]]) {
        NSTextField *field = (NSTextField *)view;
        if (!field.isEditable) {
            NSString *value = field.stringValue;
            NSString *translated = RXTranslate(value);
            if (translated.length && ![translated isEqualToString:value]) [field setStringValue:translated];
            NSAttributedString *attributed = field.attributedStringValue;
            NSString *attributedText = RXTranslate(attributed.string);
            if (attributedText.length && ![attributedText isEqualToString:attributed.string]) {
                [field setAttributedStringValue:[[NSAttributedString alloc] initWithString:attributedText attributes:[attributed attributesAtIndex:0 effectiveRange:NULL]]];
            }
        }
    }
    if ([view isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)view;
        if (!textView.isEditable) {
            NSString *value = textView.string;
            NSString *translated = RXTranslate(value);
            if (translated.length && ![translated isEqualToString:value]) [textView setString:translated];
        }
    }
    if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        NSString *rawTitle = origButtonTitleGetter ? ((NSString *(*)(id, SEL))origButtonTitleGetter)(button, @selector(title)) : button.title;
        NSString *translated = RXTranslate(rawTitle);
        if (translated.length && ![translated isEqualToString:rawTitle]) [button setTitle:translated];
        NSString *rawDescription = origButtonAccessibilityDescription ? ((NSString *(*)(id, SEL))origButtonAccessibilityDescription)(button, @selector(accessibilityDescription)) : nil;
        NSString *translatedDescription = RXTranslate(rawDescription);
        if (translatedDescription.length && ![translatedDescription isEqualToString:rawDescription] && [button respondsToSelector:@selector(setAccessibilityDescription:)]) ((void (*)(id, SEL, NSString *))objc_msgSend)(button, @selector(setAccessibilityDescription:), translatedDescription);
    }
    if ([view isKindOfClass:[NSSegmentedControl class]]) {
        NSSegmentedControl *segments = (NSSegmentedControl *)view;
        for (NSInteger i = 0; i < segments.segmentCount; i++) {
            NSString *label = [segments labelForSegment:i];
            NSString *translated = RXTranslate(label);
            if (translated.length && ![translated isEqualToString:label]) [segments setLabel:translated forSegment:i];
        }
    }
    if ([view isKindOfClass:[NSPopUpButton class]]) {
        NSPopUpButton *popup = (NSPopUpButton *)view;
        for (NSMenuItem *item in popup.itemArray) {
            NSString *translated = RXTranslate(item.title);
            if (translated.length && ![translated isEqualToString:item.title]) [item setTitle:translated];
        }
        RXTranslatePopupMenu(popup.menu);
    }
    NSString *label = view.accessibilityLabel;
    NSString *translated = RXTranslate(label);
    if (translated != label && ![translated isEqualToString:label]) view.accessibilityLabel = translated;
    NSString *help = view.accessibilityHelp;
    NSString *translatedHelp = RXTranslate(help);
    if (translatedHelp != help && ![translatedHelp isEqualToString:help]) view.accessibilityHelp = translatedHelp;
    NSString *title = view.accessibilityTitle;
    NSString *translatedTitle = RXTranslate(title);
    if (translatedTitle != title && ![translatedTitle isEqualToString:title]) view.accessibilityTitle = translatedTitle;
    NSString *rawDescription = origViewAccessibilityDescriptionGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityDescriptionGetter)(view, @selector(accessibilityDescription)) : nil;
    NSString *translatedDescription = RXTranslate(rawDescription);
    if (translatedDescription.length && ![translatedDescription isEqualToString:rawDescription] && [view respondsToSelector:@selector(setAccessibilityDescription:)]) ((void (*)(id, SEL, NSString *))objc_msgSend)(view, @selector(setAccessibilityDescription:), translatedDescription);
    if ([view isKindOfClass:[NSControl class]]) { NSCell *cell = [(NSControl *)view cell]; if (cell) RXWalkAX(cell, 0); }
    RXWalkAX(view, 0);
    for (NSView *child in view.subviews) RXWalk(child);
}

@interface RXResidualOverlayView : NSView
@property(nonatomic, copy) NSString *text;
@end

@implementation RXResidualOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [[NSColor.controlBackgroundColor colorWithAlphaComponent:1.0] setFill];
    NSRectFill(self.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:16.0],
        NSForegroundColorAttributeName: NSColor.secondaryLabelColor
    };
    [self.text drawAtPoint:NSMakePoint(0.0, 1.0) withAttributes:attributes];
}
@end

@interface RXRemoteHostPlaceholderOverlayView : NSView
@property(nonatomic, copy) NSString *text;
@end

@implementation RXRemoteHostPlaceholderOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [NSColor.textBackgroundColor setFill];
    NSRectFill(self.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:14.0],
        NSForegroundColorAttributeName: NSColor.placeholderTextColor
    };
    [self.text drawAtPoint:NSMakePoint(2.0, 4.0) withAttributes:attributes];
}
@end

@interface RXTerminalPreviewOverlayView : NSView
@end

@implementation RXTerminalPreviewOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSBezierPath *box = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5, 0.5) xRadius:11.0 yRadius:11.0];
    [NSColor.textBackgroundColor setFill];
    [box fill];
    [NSColor.separatorColor setStroke];
    [box stroke];
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont fontWithName:@"Menlo" size:15.0] ?: [NSFont monospacedSystemFontOfSize:15.0 weight:NSFontWeightRegular],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    NSArray *lines = @[
        @"~/rex | main $ Swift 构建 && Swift 测试",
        @"main.swift:4: 警告：'run() -> Bool' 已弃用",
        @"构建完成！ (1.24 秒)"
    ];
    for (NSUInteger index = 0; index < lines.count; index++) {
        [lines[index] drawAtPoint:NSMakePoint(12.0, 5.0 + index * 17.0) withAttributes:attributes];
    }
}
@end

@interface RXThemeEditorNameOverlayView : NSView
@property(nonatomic, copy) NSString *text;
@end

@implementation RXThemeEditorNameOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [NSColor.textBackgroundColor setFill];
    NSRectFill(self.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:21.0 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: NSColor.textColor
    };
    [self.text drawAtPoint:NSMakePoint(2.0, 1.0) withAttributes:attributes];
}
@end

@interface RXRemoteHostHeaderOverlayView : NSView
@end

@implementation RXRemoteHostHeaderOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [[NSColor.windowBackgroundColor colorWithAlphaComponent:1.0] setFill];
    NSRectFill(self.bounds);
    NSDictionary *titleAttributes = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:30.0],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    NSDictionary *subtitleAttributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:20.0],
        NSForegroundColorAttributeName: NSColor.secondaryLabelColor
    };
    [@"编辑主机" drawAtPoint:NSMakePoint(0.0, 0.0) withAttributes:titleAttributes];
    [@"更改将保存在此 Mac 本地。" drawAtPoint:NSMakePoint(0.0, 38.0) withAttributes:subtitleAttributes];
}
@end

@interface RXRemoteHostErrorOverlayView : NSView
@end

@implementation RXRemoteHostErrorOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [[NSColor.windowBackgroundColor colorWithAlphaComponent:1.0] setFill];
    NSRectFill(self.bounds);
    NSDictionary *titleAttributes = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:22.0],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    NSDictionary *bodyAttributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:18.0],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    [@"无法连接到 添加远程主机" drawAtPoint:NSMakePoint(0.0, 0.0) withAttributes:titleAttributes];
    NSString *body = @"找不到 添加远程主机。请检查网络连接和主机地址，并确保 Rex 正在运行，然后重试。";
    [body drawWithRect:NSMakeRect(0.0, 39.0, self.bounds.size.width, MAX(0.0, self.bounds.size.height - 39.0)) options:NSStringDrawingUsesLineFragmentOrigin attributes:bodyAttributes context:nil];
}
@end

// Rex's standard About panel is a borderless SwiftUI window. Its two visible
// lines are rendered outside the AppKit/SwiftUI text nodes that the normal
// translation hooks can reach, so cover only the lower text region while
// leaving the native icon and close button untouched.
@interface RXAboutOverlayView : NSView
@end

@implementation RXAboutOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    [NSColor.windowBackgroundColor setFill];
    NSRectFill(self.bounds);
    NSDictionary *titleAttributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:16.0 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    NSDictionary *versionAttributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:12.0],
        NSForegroundColorAttributeName: NSColor.labelColor
    };
    NSString *title = @"Rex Beta";
    NSString *version = @"版本 0.1.0 (1408)";
    NSSize titleSize = [title sizeWithAttributes:titleAttributes];
    NSSize versionSize = [version sizeWithAttributes:versionAttributes];
    [title drawAtPoint:NSMakePoint((self.bounds.size.width - titleSize.width) / 2.0, 3.0)
        withAttributes:titleAttributes];
    [version drawAtPoint:NSMakePoint((self.bounds.size.width - versionSize.width) / 2.0, 36.0)
          withAttributes:versionAttributes];
}
@end

static void RXSetAboutOverlay(NSWindow *window) {
    if (!window || window.title.length || !window.contentView) return;
    NSSize size = window.frame.size;
    // On Rex Beta 0.1.0 the standard About panel is a borderless 284x170pt
    // window (retina screenshots are 568x340px). Keep this check narrow so a
    // blank auxiliary window is never covered accidentally.
    if (size.width < 278.0 || size.width > 290.0 || size.height < 164.0 || size.height > 176.0) return;
    NSView *host = window.contentView;
    NSString *identifier = @"rex-about-text";
    RXAboutOverlayView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview isKindOfClass:[RXAboutOverlayView class]] && [subview.identifier isEqualToString:identifier]) {
            overlay = (RXAboutOverlayView *)subview;
            break;
        }
    }
    // The SwiftUI hosting view is bottom-left-origin, while this overlay is
    // flipped. A y=0 frame therefore maps to the lower text band in the
    // screenshot (the panel's titlebar/icon remain above it).
    NSRect frame = NSMakeRect(0.0, 0.0, size.width, MIN(66.0, size.height));
    if (!overlay) {
        overlay = [[RXAboutOverlayView alloc] initWithFrame:frame];
        overlay.identifier = identifier;
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.frame = frame;
    [overlay setNeedsDisplay:YES];
}

// SwiftUI presents the remote-host failure details in a borderless auxiliary
// window (426x176 on Rex Beta 0.1.0). Its title is drawn by SwiftUI rather than
// exposed as an AppKit text field, so the normal string/AX hooks cannot change
// the pixels. Cover only the title and body region; the native Retry button
// remains below it and keeps its original action.
static void RXSetRemoteHostErrorPopoverOverlay(NSWindow *window) {
    if (!window || !window.contentView) return;
    NSSize size = window.frame.size;
    if (size.width < 400.0 || size.width > 450.0 || size.height < 150.0 || size.height > 200.0) return;
    NSView *host = window.contentView;
    RXRemoteHostErrorOverlayView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview isKindOfClass:[RXRemoteHostErrorOverlayView class]] && [subview.identifier isEqualToString:@"rex-remote-host-error-popover"]) {
            overlay = (RXRemoteHostErrorOverlayView *)subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[RXRemoteHostErrorOverlayView alloc] initWithFrame:NSZeroRect];
        overlay.identifier = @"rex-remote-host-error-popover";
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.frame = NSMakeRect(16.0, 8.0, MAX(0.0, size.width - 32.0), 84.0);
    [overlay setNeedsDisplay:YES];
}

@interface RXRemoteHostSaveOverlayView : NSView
@end

@implementation RXRemoteHostSaveOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSBezierPath *button = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(self.bounds, 0.5, 0.5) xRadius:18.0 yRadius:18.0];
    [NSColor.controlAccentColor setFill];
    [button fill];
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:17.0],
        NSForegroundColorAttributeName: NSColor.whiteColor
    };
    NSSize textSize = [@"保存" sizeWithAttributes:attributes];
    [@"保存" drawAtPoint:NSMakePoint((self.bounds.size.width - textSize.width) / 2.0, (self.bounds.size.height - textSize.height) / 2.0) withAttributes:attributes];
}
@end

static void RXSetResidualOverlay(NSView *detail, NSString *key, NSString *text, NSRect frame, BOOL hidden) {
    RXResidualOverlayView *overlay = nil;
    for (NSView *subview in detail.subviews) {
        if ([subview isKindOfClass:[RXResidualOverlayView class]] && [subview.identifier isEqualToString:key]) {
            overlay = (RXResidualOverlayView *)subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[RXResidualOverlayView alloc] initWithFrame:frame];
        overlay.identifier = key;
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    [detail addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    overlay.text = text;
    overlay.frame = frame;
    overlay.hidden = hidden;
    [overlay setNeedsDisplay:YES];
}

static void RXRemoveOwnedResidualOverlays(void) {
    if (!RXOwnedResidualOverlays) return;
    for (NSView *overlay in [RXOwnedResidualOverlays allObjects]) {
        [overlay removeFromSuperview];
    }
    [RXOwnedResidualOverlays removeAllObjects];
}

static void RXRemoveResidualOverlays(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return;
    for (NSView *subview in [view.subviews copy]) {
        if ([subview isKindOfClass:[RXResidualOverlayView class]] || [subview isKindOfClass:[RXRemoteHostPlaceholderOverlayView class]] || [subview isKindOfClass:[RXTerminalPreviewOverlayView class]]) {
            [subview removeFromSuperview];
            continue;
        }
        RXRemoveResidualOverlays(subview);
    }
}

static void RXSetLocalRuntimeOverlayView(NSWindow *window, NSString *key, Class viewClass, NSRect frame);

static void RXSetThemeEditorNameOverlay(NSWindow *window, BOOL visible) {
    if (!window || !window.contentView) return;
    NSView *host = window.contentView;
    RXThemeEditorNameOverlayView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview isKindOfClass:[RXThemeEditorNameOverlayView class]] && [subview.identifier isEqualToString:@"rex-theme-editor-name"]) {
            overlay = (RXThemeEditorNameOverlayView *)subview;
            break;
        }
    }
    if (!visible || NSIsEmptyRect(RXThemeEditorNameFrame)) {
        [overlay removeFromSuperview];
        return;
    }
    NSRect frame = [window convertRectFromScreen:RXThemeEditorNameFrame];
    if (!overlay) {
        overlay = [[RXThemeEditorNameOverlayView alloc] initWithFrame:frame];
        overlay.identifier = @"rex-theme-editor-name";
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.text = @"未命名浅色主题";
    overlay.frame = [host convertRect:frame fromView:nil];
    [overlay setNeedsDisplay:YES];
}

static void RXUpdateRemoteHostSheetOverlay(NSWindow *window) {
    if (!window || !window.contentView) return;
    NSSize size = window.frame.size;
    FILE *debugFile = fopen("/tmp/rex-overlay.log", "a");
    if (debugFile) { fprintf(debugFile, "title=%s size=%.1fx%.1f flipped=%d\n", window.title.UTF8String ?: "", size.width, size.height, window.contentView.isFlipped); fclose(debugFile); }
    if (window.title.length) return;
    NSLog(@"[RexChinese] sheet frame %@ title=%@", NSStringFromRect(window.frame), window.title);
    if (size.width >= 450.0 && size.width <= 600.0 && size.height >= 400.0 && size.height <= 600.0) {
        BOOL flipped = window.contentView.isFlipped;
        NSRect headerFrame = flipped ? NSMakeRect(72.0, 18.0, size.width - 130.0, 78.0) : NSMakeRect(72.0, size.height - 96.0, size.width - 130.0, 78.0);
        NSRect saveFrame = flipped ? NSMakeRect(size.width - 82.0, size.height - 52.0, 70.0, 38.0) : NSMakeRect(size.width - 82.0, 14.0, 70.0, 38.0);
        RXSetLocalRuntimeOverlayView(window, @"rex-remote-host-header-fixed", [RXRemoteHostHeaderOverlayView class], headerFrame);
        RXSetLocalRuntimeOverlayView(window, @"rex-remote-host-save-fixed", [RXRemoteHostSaveOverlayView class], saveFrame);
        return;
    }
    if (size.width < 450.0 || size.width > 520.0 || size.height < 300.0 || size.height > 390.0) return;
    NSView *content = window.contentView;
    RXRemoteHostPlaceholderOverlayView *overlay = nil;
    for (NSView *subview in content.subviews) {
        if ([subview isKindOfClass:[RXRemoteHostPlaceholderOverlayView class]] && [subview.identifier isEqualToString:@"rex-remote-host-placeholder"]) {
            overlay = (RXRemoteHostPlaceholderOverlayView *)subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[RXRemoteHostPlaceholderOverlayView alloc] initWithFrame:NSZeroRect];
        overlay.identifier = @"rex-remote-host-placeholder";
        [content addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    overlay.text = @"主机名称";
    overlay.frame = NSMakeRect(101.0, 164.0, size.width - 131.0, 28.0);
    overlay.hidden = NO;
    [overlay setNeedsDisplay:YES];
}

static NSView *RXFindSettingsDetail(NSView *view);

static void RXSetRuntimeOverlayView(NSWindow *window, NSString *key, Class viewClass, NSRect screenFrame) {
    if (!window || NSIsEmptyRect(screenFrame) || !window.contentView) return;
    NSView *host = RXFindSettingsDetail(window.contentView) ?: window.contentView;
    NSRect windowFrame = [window convertRectFromScreen:screenFrame];
    NSRect frame = [host convertRect:windowFrame fromView:nil];
    NSView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview.identifier isEqualToString:key] && [subview isKindOfClass:viewClass]) {
            overlay = subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[viewClass alloc] initWithFrame:frame];
        overlay.identifier = key;
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.frame = frame;
    [overlay setNeedsDisplay:YES];
}

static void RXSetLocalRuntimeOverlayView(NSWindow *window, NSString *key, Class viewClass, NSRect frame) {
    if (!window || !window.contentView || NSIsEmptyRect(frame)) return;
    NSView *host = window.contentView;
    NSView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview.identifier isEqualToString:key] && [subview isKindOfClass:viewClass]) {
            overlay = subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[viewClass alloc] initWithFrame:frame];
        overlay.identifier = key;
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.frame = frame;
    [overlay setNeedsDisplay:YES];
}

static void RXTranslateThemeEditorNameInView(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return;
    if ([view isKindOfClass:[NSTextField class]]) {
        NSTextField *field = (NSTextField *)view;
        NSString *value = field.stringValue;
        if ([value isEqualToString:@"Untitled Light Theme"] || [value isEqualToString:@"**Untitled Light Theme**"]) {
            [field setStringValue:@"未命名浅色主题"];
        }
    }
    if ([view isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)view;
        NSString *value = textView.string;
        if ([value isEqualToString:@"Untitled Light Theme"] || [value isEqualToString:@"**Untitled Light Theme**"]) {
            [textView setString:@"未命名浅色主题"];
        }
    }
    for (NSView *child in view.subviews) RXTranslateThemeEditorNameInView(child);
}

static void RXUpdateRuntimeTextOverlays(NSWindow *window) {
    if (!window) return;
    FILE *debugFile = fopen("/tmp/rex-overlay.log", "a");
    if (debugFile) { fprintf(debugFile, "runtime title=%s size=%.1fx%.1f visible=%d frame=%.1f,%.1f %.1fx%.1f err=%d node=%d\n", window.title.UTF8String ?: "", window.frame.size.width, window.frame.size.height, window.isVisible, RXRemoteErrorFrame.origin.x, RXRemoteErrorFrame.origin.y, RXRemoteErrorFrame.size.width, RXRemoteErrorFrame.size.height, RXHasRemoteErrorFrame, RXHasRemoteErrorNode); fclose(debugFile); }
    RXSetAboutOverlay(window);
    if (!window.title.length && RXHasThemeEditorNameFrame) RXSetThemeEditorNameOverlay(window, YES);
    else if (!window.title.length) RXSetThemeEditorNameOverlay(window, NO);
    if (!window.title.length && window.frame.size.width >= 580.0 && window.frame.size.width <= 650.0 && window.frame.size.height >= 560.0 && window.frame.size.height <= 630.0) {
        RXTranslateThemeEditorNameInView(window.contentView);
    }
    // Rex keeps the borderless remote-error popover as a reusable 426x176
    // window, and its SwiftUI text is not present in the AppKit view tree.
    // The dimensions identify this window on Rex Beta 0.1.0; drawing the
    // translated region here makes the visible title match the translated AX
    // value even when AX does not provide a frame.
    if (!window.title.length && window.frame.size.width >= 420.0 && window.frame.size.width <= 432.0 && window.frame.size.height >= 170.0 && window.frame.size.height <= 182.0) {
        RXSetRemoteHostErrorPopoverOverlay(window);
    }
    if (RXHasRemoteHeaderFrame) RXSetRuntimeOverlayView(window, @"rex-remote-host-header", [RXRemoteHostHeaderOverlayView class], RXRemoteHeaderFrame);
    if (RXHasRemoteErrorFrame) {
        // The AX frame belongs to the title line. Expand it to cover the
        // translated body while stopping above the Retry button.
        NSRect errorFrame = RXRemoteErrorFrame;
        errorFrame.size.width = MAX(errorFrame.size.width, 400.0);
        errorFrame.size.height = MAX(errorFrame.size.height + 62.0, 78.0);
        RXSetRuntimeOverlayView(window, @"rex-remote-host-error", [RXRemoteHostErrorOverlayView class], errorFrame);
    }
    if (RXHasRemoteSaveFrame) RXSetRuntimeOverlayView(window, @"rex-remote-host-save", [RXRemoteHostSaveOverlayView class], RXRemoteSaveFrame);
}

static void RXSetWindowResidualOverlay(NSWindow *window, NSString *key, NSString *text, NSRect screenFrame) {
    if (!window || NSIsEmptyRect(screenFrame)) return;
    NSView *content = window.contentView;
    if (!content) return;
    NSView *host = RXFindSettingsDetail(content) ?: content;
    NSRect windowFrame = [window convertRectFromScreen:screenFrame];
    NSRect frame = [host convertRect:windowFrame fromView:nil];
    RXResidualOverlayView *overlay = [[RXResidualOverlayView alloc] initWithFrame:frame];
    overlay.identifier = key;
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.text = text;
    [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    [overlay setNeedsDisplay:YES];
}

static NSRect RXAccessibilityFrame(id element) {
    SEL selector = @selector(accessibilityFrame);
    if ([element respondsToSelector:selector]) {
        NSRect frame = ((NSRect (*)(id, SEL))objc_msgSend)(element, selector);
        if (!NSIsEmptyRect(frame)) return frame;
    }
    // SwiftUI accessibility nodes expose position and size separately. The
    // AXFrame convenience selector is not implemented on those nodes, so
    // derive the screen frame from the two standard attributes.
    id position = nil;
    id size = nil;
    if ([element respondsToSelector:@selector(accessibilityAttributeValue:)]) {
        id (*attributeValue)(id, SEL, NSString *) = (id (*)(id, SEL, NSString *))objc_msgSend;
        position = attributeValue(element, @selector(accessibilityAttributeValue:), NSAccessibilityPositionAttribute);
        size = attributeValue(element, @selector(accessibilityAttributeValue:), NSAccessibilitySizeAttribute);
    }
    if (![position isKindOfClass:[NSValue class]] || ![size isKindOfClass:[NSValue class]]) {
        position = RXRawAXValue(element, NSAccessibilityPositionAttribute);
        size = RXRawAXValue(element, NSAccessibilitySizeAttribute);
    }
    if ([position isKindOfClass:[NSValue class]] && [size isKindOfClass:[NSValue class]]) {
        return NSMakeRect([position pointValue].x, [position pointValue].y,
                          [size sizeValue].width, [size sizeValue].height);
    }
    id frameObject = RXRawAXValue(element, @"AXFrame");
    return [frameObject isKindOfClass:[NSValue class]] ? [frameObject rectValue] : NSZeroRect;
}

static NSView *RXFindSettingsDetail(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return nil;
    if (strcmp(class_getName(object_getClass(view)), "RexMacOS.SettingsShellDetailView") == 0) return view;
    for (NSView *child in view.subviews) {
        NSView *result = RXFindSettingsDetail(child);
        if (result) return result;
    }
    return nil;
}

static void RXUpdateSettingsResidualOverlays(NSWindow *window) {
    NSString *title = window.title ?: @"";
    if (![title hasPrefix:@"设置"] && ![title hasPrefix:@"Settings"]) return;
    RXRemoveOwnedResidualOverlays();
    NSView *detail = RXFindSettingsDetail(window.contentView);
    if (!detail) return;
    // Remove every overlay instance owned by this patch before rebuilding the
    // visible page. SwiftUI may have moved the old detail subtree elsewhere in
    // the window, so cleaning only the currently discovered detail leaves
    // stale text behind after navigation. The registry contains only views we
    // created, so native SwiftUI content is unaffected.
    RXRemoveResidualOverlays(detail);
    BOOL server = [title containsString:@"服务器"] || [title containsString:@"Server"];
    BOOL notifications = [title containsString:@"通知"] || [title containsString:@"Notifications"];
    BOOL terminal = [title containsString:@"终端"] || [title containsString:@"Terminal"];
    // SwiftUI replaces the detail subtree while navigating. Remove stale overlays
    // before adding only the overlay that belongs to the visible page.
    if (server) RXSetResidualOverlay(detail, @"rex-server-access", @"从其他设备安全访问 Rex。", NSMakeRect(74.0, 604.0, 430.0, 25.0), NO);
    if (notifications) {
        if (RXHasNotificationFrame) {
            RXSetWindowResidualOverlay(window, @"rex-notification-position", @"显示在右下角", RXNotificationFrame);
        } else {
            RXSetResidualOverlay(detail, @"rex-notification-position", @"显示在右下角", NSMakeRect(30.0, 679.0, 430.0, 25.0), NO);
        }
    }
    if (terminal) {
        RXTerminalPreviewOverlayView *preview = [[RXTerminalPreviewOverlayView alloc] initWithFrame:NSMakeRect(30.0, 676.0, 625.0, 57.0)];
        if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
        [RXOwnedResidualOverlays addObject:preview];
        preview.wantsLayer = YES;
        preview.layer.zPosition = 1000.0;
        [detail addSubview:preview positioned:NSWindowAbove relativeTo:nil];
        [preview setNeedsDisplay:YES];
        if (RXHasDefaultShellFrame) RXSetWindowResidualOverlay(window, @"rex-default-login-shell", @"默认登录 Shell", RXDefaultShellFrame);
    }
}

static void RXWalkAX(id element, NSUInteger depth) {
    if (!element || depth > 20 || ![element respondsToSelector:@selector(accessibilityAttributeValue:)]) return;
    if (RXIsOwnedOverlayObject(element)) return;
    NSArray *attrs = @[NSAccessibilityDescriptionAttribute, NSAccessibilityTitleAttribute, NSAccessibilityHelpAttribute, NSAccessibilityPlaceholderValueAttribute, NSAccessibilityValueAttribute, NSAccessibilityValueDescriptionAttribute, NSAccessibilityRoleDescriptionAttribute];
    for (NSString *attribute in attrs) {
        id value = [element accessibilityAttributeValue:attribute];
        if ([value isKindOfClass:[NSString class]]) {
            id rawObject = RXRawAXValue(element, attribute);
            NSString *rawValue = [rawObject isKindOfClass:[NSString class]] ? rawObject : value;
            NSString *translated = RXTranslate(value);
            NSRect rawFrame = RXAccessibilityFrame(element);
            if ([rawValue isEqualToString:@"Untitled Light Theme"] || [rawValue isEqualToString:@"**Untitled Light Theme**"]) {
                RXThemeEditorNameFrame = rawFrame;
                RXHasThemeEditorNameFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue containsString:@"Edit Host"] || [rawValue containsString:@"Changes are saved locally on this Mac."]) {
                RXRemoteHeaderFrame = rawFrame;
                RXHasRemoteHeaderFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue containsString:@"Couldn’t connect to"] || [rawValue containsString:@"Couldn't connect to"] ||
                [translated containsString:@"无法连接到"]) {
                RXHasRemoteErrorNode = YES;
                RXRemoteErrorFrame = rawFrame;
                RXHasRemoteErrorFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue isEqualToString:@"Save"]) {
                RXRemoteSaveFrame = rawFrame;
                RXHasRemoteSaveFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue containsString:@"Default login shell"]) {
                NSRect frame = RXAccessibilityFrame(element);
                RXDefaultShellFrame = frame;
                RXHasDefaultShellFrame = !NSIsEmptyRect(frame);
            }
            if ([rawValue containsString:@"Displayed bottom right"] || [value containsString:@"Displayed bottom right"]) {
                NSRect frame = RXAccessibilityFrame(element);
                RXNotificationFrame = frame;
                RXHasNotificationFrame = !NSIsEmptyRect(frame);
            }
            if (![translated isEqualToString:value]) {
                id frame = [element accessibilityAttributeValue:@"AXFrame"];
                NSRect rect = [frame isKindOfClass:[NSValue class]] ? [frame rectValue] : NSZeroRect;
            }
            if (![translated isEqualToString:value] && [element respondsToSelector:@selector(accessibilitySetValue:forAttribute:)]) {
                [element accessibilitySetValue:translated forAttribute:attribute];
                if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
                    [attribute isEqualToString:NSAccessibilityTitleAttribute]) {
                    NSAccessibilityPostNotification(element, NSAccessibilityValueChangedNotification);
                }
            }
            if ([attribute isEqualToString:NSAccessibilityDescriptionAttribute] && ![translated isEqualToString:value] && [element respondsToSelector:@selector(setAccessibilityDescription:)]) {
                [element setAccessibilityDescription:translated];
            }
            if ([attribute isEqualToString:NSAccessibilityPlaceholderValueAttribute] && ![translated isEqualToString:value] && [element respondsToSelector:@selector(setAccessibilityPlaceholderValue:)]) {
                [element setAccessibilityPlaceholderValue:translated];
            }
        }
    }
    id children = [element accessibilityAttributeValue:NSAccessibilityChildrenAttribute];
    if ([children isKindOfClass:[NSArray class]]) {
        for (id child in (NSArray *)children) RXWalkAX(child, depth + 1);
    }
}

static void RXRefreshToolbarItem(NSToolbarItem *item) {
    if (![item isKindOfClass:[NSToolbarItem class]]) return;
    NSString *label = item.label;
    NSString *translatedLabel = RXTranslate(label);
    if (translatedLabel.length && ![translatedLabel isEqualToString:label]) item.label = translatedLabel;
    NSString *paletteLabel = item.paletteLabel;
    NSString *translatedPaletteLabel = RXTranslate(paletteLabel);
    if (translatedPaletteLabel.length && ![translatedPaletteLabel isEqualToString:paletteLabel]) item.paletteLabel = translatedPaletteLabel;
    NSString *toolTip = item.toolTip;
    NSString *translatedToolTip = RXTranslate(toolTip);
    if (translatedToolTip.length && ![translatedToolTip isEqualToString:toolTip]) item.toolTip = translatedToolTip;
    if ([item isKindOfClass:[NSToolbarItemGroup class]]) {
        for (NSToolbarItem *child in [(NSToolbarItemGroup *)item subitems]) RXRefreshToolbarItem(child);
    }
}

static void RXRefreshToolbar(NSToolbar *toolbar) {
    if (![toolbar isKindOfClass:[NSToolbar class]]) return;
    for (NSToolbarItem *item in toolbar.items) RXRefreshToolbarItem(item);
}

static void RXInstallSegmentHooks(void) {
    if (origSegmentAccessibilityValue) return;
    // These private AX provider classes are loaded lazily with the first
    // toolbar that exposes indexed segments, so retry after windows exist.
    Class segmentClass = objc_getClass("NSAccessibilityIndexedMockUIElement");
    if (!segmentClass) segmentClass = objc_getClass("NSAccessibilitySegment");
    if (!segmentClass) return;
    origSegmentAccessibilityValue = RXHook(segmentClass, @selector(accessibilityAttributeValue:), (IMP)RXSegmentAccessibilityAttributeValue);
    origSegmentAccessibilityDescription = RXHook(segmentClass, @selector(accessibilityDescription), (IMP)RXSegmentAccessibilityDescription);
    Class concreteSegmentClass = objc_getClass("NSAccessibilitySegment");
    if (concreteSegmentClass) {
        origSegmentAccessibilityDescriptionAttribute = RXHook(concreteSegmentClass, @selector(accessibilityDescriptionAttribute), (IMP)RXSegmentAccessibilityDescriptionAttribute);
    }
    Class toolbarViewerClass = objc_getClass("NSToolbarItemViewer");
    if (toolbarViewerClass) {
        origToolbarViewerDescriptionAttribute = RXHook(toolbarViewerClass, @selector(accessibilityDescriptionAttribute), (IMP)RXToolbarViewerDescriptionAttribute);
        origToolbarViewerTitleAttribute = RXHook(toolbarViewerClass, @selector(accessibilityTitleAttribute), (IMP)RXToolbarViewerTitleAttribute);
    }
}

static void RXRefreshAccessibility(void) {
    RXInstallMenuItemHooks();
    RXInstallSwiftNodeHooks();
    RXInstallPopupHooks();
    RXInstallSegmentHooks();
    for (NSWindow *window in NSApp.windows) {
        RXHasDefaultShellFrame = NO;
        RXHasNotificationFrame = NO;
        RXHasRemoteHeaderFrame = NO;
        RXHasRemoteErrorFrame = NO;
        RXHasRemoteErrorNode = NO;
        RXHasRemoteSaveFrame = NO;
        RXHasThemeEditorNameFrame = NO;
        RXThemeEditorNameFrame = NSZeroRect;
        RXAXWalkWindow = window;
        RXRefreshToolbar(window.toolbar);
        RXWalk(window.contentView);
        RXWalkAX(window, 0);
        RXUpdateSettingsResidualOverlays(window);
        RXUpdateRemoteHostSheetOverlay(window);
        RXUpdateRuntimeTextOverlays(window);
    }
    RXAXWalkWindow = nil;
    RXRefreshMenu(NSApp.mainMenu);
}

__attribute__((constructor)) static void RexChineseInstall(void) {
    @autoreleasepool {
        Class axElement = objc_getClass("NSAccessibilityElement");
        origAXElementAttribute = axElement ? RXHook(axElement, @selector(accessibilityAttributeValue:), (IMP)RXAXElementAttribute) : NULL;
        origAXElementValue = axElement ? RXHook(axElement, @selector(accessibilityValue), (IMP)RXAXElementObject) : NULL;
        origAXElementPlaceholder = axElement ? RXHook(axElement, @selector(accessibilityPlaceholderValue), (IMP)RXAXElementObject) : NULL;
        origAXElementLabel = axElement ? RXHook(axElement, @selector(accessibilityLabel), (IMP)RXAXElementObject) : NULL;
        origAXElementTitle = axElement ? RXHook(axElement, @selector(accessibilityTitle), (IMP)RXAXElementObject) : NULL;
        origAXElementHelp = axElement ? RXHook(axElement, @selector(accessibilityHelp), (IMP)RXAXElementObject) : NULL;
        origAXElementDescription = axElement ? RXHook(axElement, @selector(accessibilityDescription), (IMP)RXAXElementObject) : NULL;
        origAXElementRoleDescription = axElement ? RXHook(axElement, @selector(accessibilityRoleDescription), (IMP)RXAXElementObject) : NULL;
        origTitle = RXHook([NSButton class], @selector(setTitle:), (IMP)RXSetTitle);
        origButtonTitleGetter = RXHook([NSButton class], @selector(title), (IMP)RXButtonTitle);
        origToolbarItemLabel = RXHook([NSToolbarItem class], @selector(setLabel:), (IMP)RXSetToolbarItemLabel);
        origToolbarItemLabelGetter = RXHook([NSToolbarItem class], @selector(label), (IMP)RXToolbarItemLabel);
        origToolbarItemPaletteLabel = RXHook([NSToolbarItem class], @selector(setPaletteLabel:), (IMP)RXSetToolbarItemPaletteLabel);
        origToolbarItemPaletteLabelGetter = RXHook([NSToolbarItem class], @selector(paletteLabel), (IMP)RXToolbarItemPaletteLabel);
        origToolbarItemToolTip = RXHook([NSToolbarItem class], @selector(setToolTip:), (IMP)RXSetToolbarItemToolTip);
        origToolbarItemToolTipGetter = RXHook([NSToolbarItem class], @selector(toolTip), (IMP)RXToolbarItemToolTip);
        origMenuTitle = RXHook([NSMenuItem class], @selector(setTitle:), (IMP)RXSetMenuTitle);
        origMenuTitleGetter = RXHook([NSMenuItem class], @selector(title), (IMP)RXMenuTitle);
        origMenuAttributedTitle = RXHook([NSMenuItem class], @selector(setAttributedTitle:), (IMP)RXSetMenuAttributedTitle);
        origMenuAttributedTitleGetter = RXHook([NSMenuItem class], @selector(attributedTitle), (IMP)RXMenuAttributedTitle);
        origMenuAccessibilityValue = RXHook([NSMenuItem class], @selector(accessibilityAttributeValue:), (IMP)RXMenuAccessibilityAttributeValue);
        origMenuAccessibilityLabel = RXHook([NSMenuItem class], @selector(accessibilityLabel), (IMP)RXMenuAccessibilityLabel);
        origMenuAccessibilityTitle = RXHook([NSMenuItem class], @selector(accessibilityTitle), (IMP)RXMenuAccessibilityTitle);
        origMenuAccessibilityDescription = RXHook([NSMenuItem class], @selector(accessibilityDescription), (IMP)RXMenuAccessibilityDescription);
        origWindowTitle = RXHook([NSWindow class], @selector(setTitle:), (IMP)RXSetWindowTitle);
        origStringValue = RXHook([NSControl class], @selector(setStringValue:), (IMP)RXSetStringValue);
        origNSTextViewSetString = RXHook([NSTextView class], @selector(setString:), (IMP)RXNSTextViewSetString);
        origNSTextViewDraw = RXHook([NSTextView class], @selector(drawRect:), (IMP)RXNSTextViewDraw);
        origPlaceholder = RXHook([NSTextField class], @selector(setPlaceholderString:), (IMP)RXSetPlaceholder);
        origPlaceholderGetter = RXHook([NSTextField class], @selector(placeholderString), (IMP)RXPlaceholder);
        origAccessibilityLabel = RXHook([NSView class], @selector(setAccessibilityLabel:), (IMP)RXSetAccessibilityLabel);
        origAccessibilityTitle = RXHook([NSView class], @selector(setAccessibilityTitle:), (IMP)RXSetAccessibilityTitle);
        origAccessibilityHelp = RXHook([NSView class], @selector(setAccessibilityHelp:), (IMP)RXSetAccessibilityHelp);
        origAccessibilityDescription = RXHook([NSView class], @selector(setAccessibilityDescription:), (IMP)RXSetAccessibilityDescription);
        origToolTip = RXHook([NSView class], @selector(setToolTip:), (IMP)RXSetToolTip);
        origViewAccessibilityLabelGetter = RXHook([NSView class], @selector(accessibilityLabel), (IMP)RXViewAccessibilityLabel);
        origViewAccessibilityTitleGetter = RXHook([NSView class], @selector(accessibilityTitle), (IMP)RXViewAccessibilityTitle);
        origViewAccessibilityHelpGetter = RXHook([NSView class], @selector(accessibilityHelp), (IMP)RXViewAccessibilityHelp);
        origViewAccessibilityDescriptionGetter = RXHook([NSView class], @selector(accessibilityDescription), (IMP)RXViewAccessibilityDescription);
        origViewAccessibilityPlaceholderGetter = RXHook([NSView class], @selector(accessibilityPlaceholderValue), (IMP)RXViewAccessibilityPlaceholder);
        origViewAccessibilityValueGetter = RXHook([NSView class], @selector(accessibilityValue), (IMP)RXViewAccessibilityValue);
        origViewAccessibilityValueDescriptionGetter = RXHook([NSView class], @selector(accessibilityValueDescription), (IMP)RXViewAccessibilityValueDescription);
        origViewAccessibilityRoleDescriptionGetter = RXHook([NSView class], @selector(accessibilityRoleDescription), (IMP)RXViewAccessibilityRoleDescription);
        origAccessibilityValue = RXHook([NSView class], @selector(accessibilityAttributeValue:), (IMP)RXAccessibilityAttributeValue);
        origCellStringValue = RXHook([NSCell class], @selector(stringValue), (IMP)RXCellStringValue);
        origCellSetStringValue = RXHook([NSCell class], @selector(setStringValue:), (IMP)RXCellSetStringValue);
        RXInstallDrawingHooks();
        RXInstallPopupHooks();
        origBundleLocalized = RXHook([NSBundle class], @selector(localizedStringForKey:value:table:), (IMP)RXBundleLocalized);
        Class splitClass = objc_getClass("SuperSplit.SuperSplitLayoutAccessibilityNSView");
        origSplitChildren = splitClass ? RXHook(splitClass, @selector(accessibilityChildren), (IMP)RXSplitChildren) : NULL;
        origSplitters = splitClass ? RXHook(splitClass, @selector(accessibilitySplitters), (IMP)RXSplitters) : NULL;
        origButtonAccessibilityLabel = RXHook([NSButton class], @selector(setAccessibilityLabel:), (IMP)RXSetButtonAccessibilityLabel);
        origButtonAccessibilityTitle = RXHook([NSButton class], @selector(setAccessibilityTitle:), (IMP)RXSetButtonAccessibilityTitle);
        origButtonAccessibilityHelp = RXHook([NSButton class], @selector(setAccessibilityHelp:), (IMP)RXSetButtonAccessibilityHelp);
        origButtonAccessibilityDescription = RXHook([NSButton class], @selector(accessibilityDescription), (IMP)RXButtonAccessibilityDescription);
        origCellAccessibilityLabel = RXHook([NSCell class], @selector(accessibilityLabel), (IMP)RXCellLabel);
        origCellAccessibilityTitle = RXHook([NSCell class], @selector(accessibilityTitle), (IMP)RXCellTitle);
        origCellAccessibilityHelp = RXHook([NSCell class], @selector(accessibilityHelp), (IMP)RXCellHelp);
        origCellAccessibilityValue = RXHook([NSCell class], @selector(accessibilityAttributeValue:), (IMP)RXCellAttributeValue);
        RXInstallSwiftNodeHooks();
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidBeginTrackingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                RXRefreshMenu(note.object);
                RXRefreshMenu(NSApp.mainMenu);
            }];
            [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer *timer) {
                RXInstallCommandPaletteHooks();
                RXInstallTextFieldTextViewHook();
            }];
            NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 repeats:YES block:^(NSTimer *timer) { RXRefreshAccessibility(); }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    }
}
