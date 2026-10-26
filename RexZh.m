#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#include <dlfcn.h>
#include <string.h>

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
            @"Dynamic": @"动态",
            @"Choose…": @"选择…",
            @"Choose...": @"选择…",
            @"Startup command": @"启动命令",
            @"Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal’s working directory when available. Otherwise, they use the server’s default directory.": @"可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
            @"Filter Shortcuts": @"筛选快捷键",
            @"Filter Shortcuts…": @"筛选快捷键…",
            @"Displayed bottom right": @"显示在右下角",
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
            @"Previous Session": @"上一个会话",
            @"Next Session": @"下一个会话",
            @"Rex Beta Diagnostics": @"Rex Beta 诊断",
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
            @"Merino Dark": @"Merino 深色",
            @"Abyssal Trench": @"深渊海沟",
            @"Basalt Shore": @"玄武岩海岸",
            @"Neon Arcade": @"霓虹街机",
            @"Static Noir": @"静态黑色",
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
    if ([s hasPrefix:@"Running for "]) return [NSString stringWithFormat:@"已运行%@", [s substringFromIndex:11]];
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

static IMP origTitle, origButtonTitleGetter, origMenuTitle, origMenuTitleGetter, origMenuAttributedTitle, origMenuAttributedTitleGetter, origMenuAccessibilityValue, origMenuAccessibilityLabel, origMenuAccessibilityTitle, origMenuAccessibilityDescription, origWindowTitle, origStringValue, origPlaceholder, origPlaceholderGetter, origAccessibilityLabel, origAccessibilityTitle, origAccessibilityHelp, origToolTip, origAccessibilityValue, origSegmentAccessibilityValue, origSegmentAccessibilityDescription, origPopupTitleOfSelectedItem, origPopupCellTitle, origViewAccessibilityLabelGetter, origViewAccessibilityTitleGetter, origViewAccessibilityHelpGetter, origViewAccessibilityValueGetter, origViewAccessibilityValueDescriptionGetter, origViewAccessibilityRoleDescriptionGetter, origButtonAccessibilityLabel, origButtonAccessibilityTitle, origButtonAccessibilityHelp, origBundleLocalized, origSplitChildren, origSplitters, origCellStringValue, origCellSetStringValue, origCellAccessibilityLabel, origCellAccessibilityTitle, origCellAccessibilityHelp, origCellAccessibilityValue, origSwiftLabel, origSwiftHelp, origSwiftAttribute, origSwiftValue, origSwiftValueDescription, origSwiftRoleDescription, origSwiftAttributedLabel;
static IMP origAXElementAttribute, origAXElementValue, origAXElementPlaceholder, origAXElementLabel, origAXElementTitle, origAXElementHelp, origAXElementRoleDescription;
static __thread BOOL RXInAXElementHook;
static NSMutableDictionary *RXPopupOriginals;
static NSMutableDictionary *RXMenuItemOriginals;
static void RXRefreshMenu(NSMenu *menu);
static void RXTranslatePopupMenu(NSMenu *menu);
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
    IMP original = (_cmd == @selector(accessibilityValue)) ? origAXElementValue : (_cmd == @selector(accessibilityPlaceholderValue) ? origAXElementPlaceholder : (_cmd == @selector(accessibilityLabel) ? origAXElementLabel : (_cmd == @selector(accessibilityTitle) ? origAXElementTitle : (_cmd == @selector(accessibilityHelp) ? origAXElementHelp : origAXElementRoleDescription))));
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
        @selector(accessibilityLabel), @selector(accessibilityHelp), @selector(accessibilityAttributeValue:),
        @selector(accessibilityValue), @selector(accessibilityValueDescription), @selector(accessibilityRoleDescription),
        @selector(accessibilityAttributedLabel)
    };
    IMP replacements[] = {
        (IMP)RXSwiftLabel, (IMP)RXSwiftHelp, (IMP)RXSwiftAttribute, (IMP)RXSwiftValue,
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

static void RXDumpMenuDiagnostics(void) {
    FILE *file = fopen("/tmp/rex-menu-diag.log", "w");
    if (!file) return;
    for (NSMenuItem *item in NSApp.mainMenu.itemArray) {
        NSString *topDescription = [item accessibilityAttributeValue:NSAccessibilityDescriptionAttribute];
        fprintf(file, "TOP class=%s title=%s label=%s axTitle=%s desc=%s\n", class_getName(object_getClass(item)), item.title.UTF8String ?: "", item.accessibilityLabel.UTF8String ?: "", item.accessibilityTitle.UTF8String ?: "", topDescription.UTF8String ?: "");
        for (Class cls = object_getClass(item); cls && cls != [NSObject class]; cls = class_getSuperclass(cls)) {
            unsigned int methodCount = 0;
            Method *methods = class_copyMethodList(cls, &methodCount);
            for (unsigned int i = 0; i < methodCount; i++) fprintf(file, "  TOPMETHOD class=%s sel=%s imp=%p\n", class_getName(cls), sel_getName(method_getName(methods[i])), method_getImplementation(methods[i]));
            free(methods);
        }
        for (NSMenuItem *child in item.submenu.itemArray) {
            NSString *childDescription = [child accessibilityAttributeValue:NSAccessibilityDescriptionAttribute];
            fprintf(file, "CHILD class=%s title=%s label=%s axTitle=%s desc=%s\n", class_getName(object_getClass(child)), child.title.UTF8String ?: "", child.accessibilityLabel.UTF8String ?: "", child.accessibilityTitle.UTF8String ?: "", childDescription.UTF8String ?: "");
            for (Class cls = object_getClass(child); cls && cls != [NSObject class]; cls = class_getSuperclass(cls)) {
                unsigned int methodCount = 0;
                Method *methods = class_copyMethodList(cls, &methodCount);
                for (unsigned int i = 0; i < methodCount; i++) {
                    SEL sel = method_getName(methods[i]);
                    if (strstr(class_getName(cls), "SwiftUI.SwiftUIMenuItem") != NULL) fprintf(file, "  METHOD class=%s sel=%s imp=%p\n", class_getName(cls), sel_getName(sel), method_getImplementation(methods[i]));
                }
                free(methods);
            }
        }
    }
    fclose(file);
}

static void RXDumpPopupDiagnostics(void) {
    FILE *file = fopen("/tmp/rex-popup-diag.log", "w");
    if (!file) return;
    unsigned int count = objc_getClassList(NULL, 0);
    Class *classes = (Class *)calloc(count, sizeof(Class));
    objc_getClassList(classes, count);
    for (unsigned int i = 0; i < count; i++) {
        const char *name = class_getName(classes[i]);
        if (!strstr(name, "PopUp") && !strstr(name, "Popup") && !strstr(name, "Picker") && !strstr(name, "Accessibility")) continue;
        fprintf(file, "CLASS %s\n", name);
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(classes[i], &methodCount);
        for (unsigned int j = 0; j < methodCount; j++) fprintf(file, "  %s\n", sel_getName(method_getName(methods[j])));
        free(methods);
    }
    free(classes);
    fclose(file);
}

static void RXDumpPopupControls(void) {
    FILE *file = fopen("/tmp/rex-popup-controls.log", "w");
    if (!file) return;
    for (NSWindow *window in NSApp.windows) {
        NSMutableArray *stack = [NSMutableArray arrayWithObject:window.contentView ?: [NSNull null]];
        while (stack.count) {
            id value = stack.lastObject;
            [stack removeLastObject];
            if (![value isKindOfClass:[NSView class]]) continue;
            NSView *view = value;
            if ([view isKindOfClass:[NSPopUpButton class]]) {
                NSPopUpButton *popup = (NSPopUpButton *)view;
                id axValue = [popup accessibilityAttributeValue:NSAccessibilityValueAttribute];
                id propertyValue = popup.accessibilityValue;
                id cellValue = [popup.cell respondsToSelector:@selector(accessibilityValue)] ? [popup.cell accessibilityValue] : nil;
                id cellAX = [popup.cell respondsToSelector:@selector(accessibilityAttributeValue:)] ? [popup.cell accessibilityAttributeValue:NSAccessibilityValueAttribute] : nil;
                fprintf(file, "POP class=%s cell=%s selected=%s title=%s ax=%s prop=%s cellProp=%s cellAX=%s set=%d\n", class_getName(object_getClass(popup)), class_getName(object_getClass(popup.cell)), popup.titleOfSelectedItem.UTF8String ?: "", popup.title.UTF8String ?: "", [axValue isKindOfClass:[NSString class]] ? [axValue UTF8String] : "", [propertyValue isKindOfClass:[NSString class]] ? [propertyValue UTF8String] : "", [cellValue isKindOfClass:[NSString class]] ? [cellValue UTF8String] : "", [cellAX isKindOfClass:[NSString class]] ? [cellAX UTF8String] : "", [popup respondsToSelector:@selector(setAccessibilityValue:)]);
            }
            [stack addObjectsFromArray:view.subviews];
        }
    }
    fclose(file);
}

static void RXDumpViewTree(NSView *view, NSUInteger depth, FILE *file) {
    if (![view isKindOfClass:[NSView class]] || depth > 40) return;
    NSString *title = nil;
    NSString *stringValue = nil;
    if ([view isKindOfClass:[NSButton class]]) {
        title = origButtonTitleGetter ? ((NSString *(*)(id, SEL))origButtonTitleGetter)(view, @selector(title)) : ((NSButton *)view).title;
    }
    if ([view isKindOfClass:[NSControl class]]) {
        NSCell *cell = [(NSControl *)view cell];
        if (cell && origCellStringValue) stringValue = ((NSString *(*)(id, SEL))origCellStringValue)(cell, @selector(stringValue));
    }
    if ([view isKindOfClass:[NSSegmentedControl class]]) {
        NSSegmentedControl *segments = (NSSegmentedControl *)view;
        NSMutableArray *labels = [NSMutableArray array];
        for (NSInteger i = 0; i < segments.segmentCount; i++) [labels addObject:[segments labelForSegment:i] ?: @""];
        stringValue = [labels componentsJoinedByString:@" | "];
    }
    NSString *label = origViewAccessibilityLabelGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityLabelGetter)(view, @selector(accessibilityLabel)) : nil;
    NSString *accessibilityTitle = origViewAccessibilityTitleGetter ? ((NSString *(*)(id, SEL))origViewAccessibilityTitleGetter)(view, @selector(accessibilityTitle)) : nil;
    if (title.length || stringValue.length || label.length || accessibilityTitle.length) {
        fprintf(file, "%*sVIEW class=%s title=%s string=%s label=%s axTitle=%s\\n", (int)(depth * 2), "", class_getName(object_getClass(view)), title.UTF8String ?: "", stringValue.UTF8String ?: "", label.UTF8String ?: "", accessibilityTitle.UTF8String ?: "");
    }
    for (NSView *child in view.subviews) RXDumpViewTree(child, depth + 1, file);
}

static void RXDumpViews(void) {
    FILE *file = fopen("/tmp/rex-view-diag.log", "w");
    if (!file) return;
    for (NSWindow *window in NSApp.windows) RXDumpViewTree(window.contentView, 0, file);
    fclose(file);
}

static void RXDumpLayerTree(CALayer *layer, NSUInteger depth, FILE *file) {
    if (![layer isKindOfClass:[CALayer class]] || depth > 40) return;
    NSString *string = [layer isKindOfClass:[CATextLayer class]] ? [(CATextLayer *)layer string] : nil;
    fprintf(file, "%*sLAYER class=%s string=%s delegate=%s\n", (int)(depth * 2), "", class_getName(object_getClass(layer)), string.UTF8String ?: "", class_getName(object_getClass(layer.delegate)));
    for (CALayer *child in layer.sublayers) RXDumpLayerTree(child, depth + 1, file);
}

static void RXDumpLayers(void) {
    static BOOL dumped;
    if (dumped) return;
    dumped = YES;
    FILE *file = fopen("/tmp/rex-layer-diag.log", "w");
    if (!file) return;
    for (NSWindow *window in NSApp.windows) RXDumpLayerTree(window.contentView.layer, 0, file);
    fclose(file);
}

static void RXWalkAX(id element, NSUInteger depth);

static void RXWalk(NSView *view) {
    if (![view isKindOfClass:[NSView class]]) return;
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
    if ([view isKindOfClass:[NSButton class]]) {
        NSButton *button = (NSButton *)view;
        NSString *rawTitle = origButtonTitleGetter ? ((NSString *(*)(id, SEL))origButtonTitleGetter)(button, @selector(title)) : button.title;
        NSString *translated = RXTranslate(rawTitle);
        if (translated.length && ![translated isEqualToString:rawTitle]) [button setTitle:translated];
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
            if (![translated isEqualToString:value]) {
                id frame = [element accessibilityAttributeValue:@"AXFrame"];
                NSRect rect = [frame isKindOfClass:[NSValue class]] ? [frame rectValue] : NSZeroRect;
            }
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
    RXInstallMenuItemHooks();
    RXInstallSwiftNodeHooks();
    RXInstallPopupHooks();
    for (NSWindow *window in NSApp.windows) {
        RXWalk(window.contentView);
        RXWalkAX(window, 0);
    }
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
        origAXElementRoleDescription = axElement ? RXHook(axElement, @selector(accessibilityRoleDescription), (IMP)RXAXElementObject) : NULL;
        origTitle = RXHook([NSButton class], @selector(setTitle:), (IMP)RXSetTitle);
        origButtonTitleGetter = RXHook([NSButton class], @selector(title), (IMP)RXButtonTitle);
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
        RXInstallPopupHooks();
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
        RXInstallSwiftNodeHooks();
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidBeginTrackingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                RXRefreshMenu(note.object);
                RXRefreshMenu(NSApp.mainMenu);
            }];
            [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer *timer) { RXInstallCommandPaletteHooks(); }];
            NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 repeats:YES block:^(NSTimer *timer) { RXRefreshAccessibility(); }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    }
}
