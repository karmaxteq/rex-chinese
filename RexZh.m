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
    static NSSet *translatedValues;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        map = @{
            @"Waiting for permission": @"正在等待权限",
            @"Unsupported block": @"不支持的内容块",
            @"The content environment does not provide the capabilities required by this block.": @"当前内容环境不具备此内容块所需的功能。",
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
            @"Dismiss editing": @"结束编辑",
            @"Settings categories": @"设置类别",
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
            @"https://example.com or https://*.example.com": @"https://example.com 或 https://*.example.com",
            @"Color": @"颜色",
            @"Background color": @"背景色",
            @"Text color": @"文本色",
            @"Cursor color": @"光标颜色",
            @"Cursor text color": @"光标文本颜色",
            @"Selection color": @"选择颜色",
            @"Selected text color": @"选中文本颜色",
            @"Hue": @"色相",
            @"Chroma": @"色度",
            @"Lightness": @"亮度",
            @"degrees": @"度",
            @"OK": @"好",
            @"Open": @"打开",
            @"Search": @"搜索",
            @"New Folder": @"新建文件夹",
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
            @"Clear text": @"清除文本",
            @"All Settings": @"所有设置",
            @"Filter Hosts": @"筛选主机",
            @"Filter hosts": @"筛选主机",
            @"All hosts": @"所有主机",
            @"Filter": @"筛选",
            @"Sidebar Tabs": @"侧边栏标签页",
            @"Insert Path": @"插入路径",
            @"Path": @"路径",
            @"folder": @"文件夹",
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
            @"Couldn’t reach": @"无法连接到",
            @"Couldn't reach": @"无法连接到",
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
            @"About Rex Beta": @"关于 Rex Beta",
            @"About Rex Beta…": @"关于 Rex Beta…",
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
            @"Hide Rex Beta": @"隐藏 Rex Beta",
            @"Hide Others": @"隐藏其他",
            @"Show All": @"显示全部",
            @"Quit Rex Beta": @"退出 Rex Beta",
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
            @"Blink interval in milliseconds": @"闪烁间隔（毫秒）",
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
            @" — Dynamic": @" — 动态",
            @" result": @" 项结果",
            @" results": @" 项结果",
            @"See the keys bound to ": @"查看绑定到 ",
            @" and where each came from.": @" 的按键及其来源。",
            @"Record, remove, or reset the keys bound to ": @"录制、移除或重置以下操作的按键：",
            @"Choose…": @"选择…",
            @"Choose...": @"选择…",
            @"Startup command": @"启动命令",
            @"Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal’s working directory when available. Otherwise, they use the server’s default directory.": @"可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
            @"Filter Shortcuts": @"筛选快捷键",
            @"Filter Shortcuts…": @"筛选快捷键…",
            @"Displayed bottom right": @"显示在右下角",
            @"Displayed top left": @"显示在左上角",
            @"Displayed top center": @"显示在顶部居中",
            @"Displayed top right": @"显示在右上角",
            @"Displayed bottom left": @"显示在左下角",
            @"Displayed bottom center": @"显示在底部居中",
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
            @"Diagnostics": @"诊断",
            @"Rex Binary": @"Rex 二进制",
            @"Installation": @"安装",
            @"Kind": @"类型",
            @"Included with Rex.app": @"Rex.app 随附",
            @"Live Logs": @"实时日志",
            @"Stop Server": @"停止服务器",
            @"Clear Logs": @"清除日志",
            @"Show Inspector": @"显示检查器",
            @"Invoke": @"调用",
            @"Method": @"方法",
            @"JSON Payload": @"JSON 负载",
            @"Send": @"发送",
            @"Calls": @"调用",
            @"Clear": @"清除",
            @"Events": @"事件",
            @"All Sessions": @"所有会话",
            @"recorded": @"已记录",
            @"Terminal Policy": @"终端策略",
            @"Scheme": @"方案",
            @"Cursor Blink": @"光标闪烁",
            @"Option Key": @"Option 键",
            @"Event": @"事件",
            @"Sessions": @"会话",
            @"Hosts": @"主机",
            @"Migrated": @"已迁移",
            @"Pending Changes": @"待处理变更",
            @"Launch to First Drawable Frame": @"启动到首个可绘制帧",
            @"Launch": @"启动",
            @"Prewarm": @"预热",
            @"Last Host": @"上一个主机",
            @"Reset": @"重置",
            @"Name": @"名称",
            @"Icon": @"图标",
            @"Connection": @"连接",
            @"Resumes": @"恢复",
            @"Last Resume Failed": @"上次恢复失败",
            @"Locators": @"地址",
            @"Preferred URL": @"首选 URL",
            @"Instance ID": @"实例 ID",
            @"Host ID": @"主机 ID",
            @"Client ID": @"客户端 ID",
            @"Last Failure": @"上次失败",
            @"Usage": @"使用情况",
            @"Now": @"当前",
            @"Mean": @"平均",
            @"Peak": @"峰值",
            @"Last 120 Seconds": @"最近 120 秒",
            @"Other Processes": @"其他进程",
            @"Total": @"总计",
            @"Copy Rex event": @"复制 Rex 事件",
            @"Copy event": @"复制事件",
            @"Shares are of one GPU's time over each one-second sample. WindowServer composites Rex's transparent terminals over the window's glass and blur, so terminal output that redraws often shows up there rather than under Rex. Other windows also add to WindowServer's share. Use script/gpu-usage.py to record the same counters from Terminal.": @"每个一秒采样点中的占比是单个 GPU 时间的占比。WindowServer 会将 Rex 的透明终端合成到窗口的玻璃和模糊效果上，因此经常重绘的终端输出通常会显示在 WindowServer 下，而不是 Rex 下。其他窗口也会增加 WindowServer 的占比。使用 script/gpu-usage.py 可从终端记录相同的计数器。",
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
            @"Click to choose a color. Drag onto another swatch to swap.": @"点击选择颜色。拖到另一个色板上即可交换。",
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
            @"Undo": @"撤销",
            @"Redo": @"重做",
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
            @"Preview": @"预览",
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
            @"Waiting for the next key after": @"正在等待下一个按键，当前按键：",
            @"Tailscale isn't connected.": @"Tailscale 未连接。",
            @"Tailscale isn’t connected.": @"Tailscale 未连接。",
            @"Tailscale notifications denied; attention remains in the menu bar": @"Tailscale 通知已被拒绝；请在菜单栏中处理。",
            @"Waiting for a key.": @"正在等待按键。",
            @"Exit Full Screen": @"退出全屏",
            @"Migrate theme from Ghostty config": @"从 Ghostty 配置迁移主题",
            @"Filter custom themes": @"筛选自定义主题",
            @"Choose a Ghostty theme or an iTerm color file.": @"选择 Ghostty 主题或 iTerm 颜色文件。",
            @"Enable Terminal Font Smoothing": @"启用终端字体平滑",
            @"Enable Terminal Font Ligatures": @"启用终端连字",
            @"Enable Display P3 Color Space": @"启用 Display P3 色彩空间",
            @"Enable Force Cursor Style": @"启用强制光标样式",
            @"Enable Autobalance Splits": @"启用自动平衡分栏",
            @"Enable Focus Follows Mouse": @"启用焦点跟随鼠标",
            @"Enable Highlight Active Pane": @"启用突出显示活动窗格",
            @"Enable Text Contrast Correction": @"启用文本对比度校正",
            @"Show Pane Headers": @"显示窗格标题",
            @"Hide Pane Headers": @"隐藏窗格标题",
            @"Disable Text Contrast Correction": @"停用文本对比度校正",
            @"Disable Highlight Active Pane": @"停用突出显示活动窗格",
            @"Disable Focus Follows Mouse": @"停用焦点跟随鼠标",
            @"Disable Autobalance Splits": @"停用自动平衡分栏",
            @"Disable Force Cursor Style": @"停用强制光标样式",
            @"Disable Display P3 Color Space": @"停用 Display P3 色彩空间",
            @"Disable Terminal Font Ligatures": @"停用终端连字",
            @"Disable Terminal Font Smoothing": @"停用终端字体平滑",
            @"Disable Rounded Selection Corners": @"停用选区圆角",
            @"Cursor Blink Interval": @"光标闪烁间隔",
            @"Set Cursor Blink Interval to": @"将光标闪烁间隔设为",
            @"Choose a preset or enter a whole number from": @"选择预设，或输入一个整数，范围为",
            @"Option Key Behavior": @"Option 键行为",
            @"Select Option Key Behavior": @"选择 Option 键行为",
            @"Select Cursor Style": @"选择光标样式",
            @"Keyboard Shortcut": @"键盘快捷键",
            @"Cancel Recording": @"取消录制",
            @"Change Shortcut": @"更改快捷键",
            @"Record Shortcut": @"录制快捷键",
            @"Restore the default shortcut.": @"恢复默认快捷键。",
            @"Restore Default Shortcut": @"恢复默认快捷键",
            @"Keep the shortcut as it was.": @"保留原快捷键。",
            @"Record a shortcut": @"录制快捷键",
            @"Type Shortcut": @"输入快捷键",
            @"Type Shortcut...": @"输入快捷键…",
            @"Type Shortcut…": @"输入快捷键…",
            @"This release cannot be installed on this Mac.": @"此版本无法安装在此 Mac 上。",
            @"Rex App Update Failed": @"Rex 应用更新失败",
            @"Retry Rex App Update": @"重试 Rex 应用更新",
            @"Check Rex App for Updates": @"检查 Rex 应用更新",
            @"Rex App Is Up to Date": @"Rex 应用已是最新版本",
            @"Installing Rex App Update": @"正在安装 Rex 应用更新",
            @"Preparing Rex App Update": @"正在准备 Rex 应用更新",
            @"Download Rex Update": @"下载 Rex 更新",
            @"Restart to Update Rex": @"重新启动以更新 Rex",
            @"Ready to Check for Updates": @"可以检查更新",
            @"Installing update": @"正在安装更新",
            @"Update installed.": @"更新已安装。",
            @"Your terminal tabs won't be lost": @"终端标签页不会丢失",
            @"Preparing update": @"正在准备更新",
            @"Checking for updates": @"正在检查更新",
            @"Relaunch to Update": @"重新启动以更新",
            @"Waiting for Rex Server to start.": @"正在等待 Rex 服务器启动。",
            @"Approve this device in the Tailscale admin console.": @"在 Tailscale 管理控制台中批准此设备。",
            @"HTTPS status isn’t available.": @"HTTPS 状态不可用。",
            @"HTTPS status isn't available.": @"HTTPS 状态不可用。",
            @"Serving over Tailscale.": @"正在通过 Tailscale 提供服务。",
            @"Waiting for an HTTPS certificate": @"正在等待 HTTPS 证书",
            @"Then retry serving.": @"然后重试共享。",
            @"Tailscale isn’t available in this version of Rex.": @"此版本的 Rex 不支持 Tailscale。",
            @"Tailscale isn't available in this version of Rex.": @"此版本的 Rex 不支持 Tailscale。",
            @"Not serving over Tailscale.": @"未通过 Tailscale 提供服务。",
            @"Sign in to Tailscale to start serving.": @"登录 Tailscale 以开始共享。",
            @"Show pairing QR code": @"显示配对二维码",
            @"Show QR code to pair a device": @"显示用于配对设备的二维码",
            @"Signed in to Tailscale": @"已登录 Tailscale",
            @"Signing out of Tailscale": @"正在退出 Tailscale",
            @"Sign Out": @"退出登录",
            @"Removing this Mac’s saved Tailscale login": @"正在移除此 Mac 保存的 Tailscale 登录信息",
            @"Removing this Mac's saved Tailscale login": @"正在移除此 Mac 保存的 Tailscale 登录信息",
            @"Ready to connect...": @"准备连接…",
            @"Finish the process in your browser.": @"在浏览器中完成此流程。",
            @"Preparing to sign in...": @"正在准备登录…",
            @"This may take a moment.": @"可能需要一点时间。",
            @"Start the Rex Server to sign in.": @"启动 Rex 服务器以登录。",
            @"Choose a hostname and optional tags for this Mac.": @"为此 Mac 选择主机名和可选标签。",
            @"Use tags like tag:name. A name starts with a letter and uses only letters, numbers, or hyphens.": @"使用 tag:name 之类的标签。名称以字母开头，只能包含字母、数字或连字符。",
            @"Compatibility hasn’t been checked yet.": @"尚未检查兼容性。",
            @"Compatibility hasn't been checked yet.": @"尚未检查兼容性。",
            @"Restart using the server included with this app.": @"使用此应用随附的服务器重新启动。",
            @"Update Rex.app, or restart from source.": @"更新 Rex.app，或从源代码重新启动。",
            @"Update Rex.app, or restart using its included server.": @"更新 Rex.app，或使用其随附服务器重新启动。",
            @"Update the app, or restart from source.": @"更新应用，或从源代码重新启动。",
            @"Restart from source to reconnect.": @"从源代码重新启动以重新连接。",
            @"Restart to apply them.": @"重新启动以应用更改。",
            @"Restart to apply them and enable newer features.": @"重新启动以应用更改并启用新功能。",
            @"Restart the server to enable them.": @"重新启动服务器以启用这些功能。",
            @"Running from source checkout": @"正在从源代码检出运行",
            @"less than a minute": @"不到一分钟",
            @"Server supports": @"服务器支持",
            @"Rex.app supports": @"Rex.app 支持",
            @"Rex.app uses Revision": @"Rex.app 使用修订版",
            @"Built from source on restart": @"重新启动时从源代码构建",
            @"Restarting is optional.": @"重新启动是可选的。",
            @"Choose the Rex server to send calls to": @"选择要发送调用的 Rex 服务器",
            @"retrying in": @"将在…后重试",
            @"Start the managed Rex server to open its API stream.": @"启动受管理的 Rex 服务器以打开 API 流。",
            @"Retry Subscription": @"重试订阅",
            @"No events received.": @"未收到事件。",
            @"Subscribing to all sessions": @"正在订阅所有会话",
            @"Waiting for Rex events.": @"正在等待 Rex 事件。",
            @"Subscription Failed": @"订阅失败",
            @"No API calls yet.": @"尚无 API 调用。",
            @"Blank input is distinct from an empty JSON object.": @"空输入不同于空 JSON 对象。",
            @"Optional; blank sends no payload": @"可选；留空时不发送载荷",
            @"Resolved endpoint": @"已解析端点",
            @"Attached clients": @"已附加客户端",
            @"Attached at an unknown time": @"附加时间未知",
            @"Pending Mutations": @"待处理变更",
            @"Pending Pane Commands": @"待处理窗格命令",
            @"Launch to First Drawable": @"启动到首个可绘制帧",
            @"Rex not connected": @"Rex 未连接",
            @"connection lost": @"连接已丢失",
            @"Not inspected yet": @"尚未检查",
            @"Rex installation": @"Rex 安装",
            @"Grant Permissions for Rex": @"授予 Rex 权限",
            @"Drag into the list in System Settings to grant access.": @"将其拖入系统设置中的列表以授予访问权限。",
            @"Full Disk Access": @"完全磁盘访问权限",
            @"Couldn’t read Rex Server’s permissions:": @"无法读取 Rex 服务器的权限：",
            @"Couldn't read Rex Server's permissions:": @"无法读取 Rex 服务器的权限：",
            @"Update Rex to see whether Rex Server has these permissions. You can still grant them in System Settings.": @"更新 Rex 以查看 Rex 服务器是否拥有这些权限。你仍可在系统设置中授予这些权限。",
            @"Rex Server is too old to report its permissions. You can still grant them, and you’ll see their status after Rex updates.": @"Rex 服务器版本过旧，无法报告权限。你仍可授予权限，Rex 更新后即可查看状态。",
            @"Rex Server is too old to report its permissions. You can still grant them, and you'll see their status after Rex updates.": @"Rex 服务器版本过旧，无法报告权限。你仍可授予权限，Rex 更新后即可查看状态。",
            @"Waiting for Rex Server on this Mac to start": @"正在等待此 Mac 上的 Rex 服务器启动",
            @"Lets command-line tools and agents reach devices on your local network.": @"允许命令行工具和智能体访问本地网络上的设备。",
            @"Lets command-line tools and agents use the camera.": @"允许命令行工具和智能体使用摄像头。",
            @"Lets command-line tools and agents record from the microphone.": @"允许命令行工具和智能体使用麦克风录音。",
            @"Lets command-line tools and agents capture the screen, windows, and system audio.": @"允许命令行工具和智能体录制屏幕、窗口和系统音频。",
            @"Lets command-line tools and agents open files in protected folders, like ~/Downloads and sandboxed apps’ containers.": @"允许命令行工具和智能体打开受保护文件夹中的文件，例如 ~/Downloads 和沙盒应用容器中的文件。",
            @"Rex.app is not accepting actions. Turn on Remote Control in its Settings under Rex Server.": @"Rex.app 不接受操作。请在“Rex 服务器”设置中打开“远程控制”。",
            @"does not offer": @"不提供",
            @"has no window to act in.": @"没有可执行操作的窗口。",
            @"isn’t available here right now.": @"当前无法使用。",
            @"isn't available here right now.": @"当前无法使用。",
            @" is still running.": @"仍在运行。",
            @" isn't available here right now.": @"当前无法使用。",
            @" is not a valid JSON pointer to a member.": @"不是有效的 JSON 指针成员。",
            @" is not a valid JSON pointer to a member. It must start with \"/\", write \"~\" as \"~0\", and not end in \"-\".": @"不是有效的 JSON 指针成员。必须以“/”开头，将“~”写作“~0”，且不能以“-”结尾。",
            @"Browser origins allowed to open Rex WebSocket streams.": @"允许打开 Rex WebSocket 流的浏览器来源。",
            @"Default origin, always allowed": @"默认来源，始终允许",
            @"No folder selected": @"未选择文件夹",
            @"Source Checkout Unavailable": @"源代码检出不可用",
            @"Preparing Source Checkout": @"正在准备源代码检出",
            @"Runs directly from a local checkout.": @"直接从本地检出运行。",
            @"Uses the Rex helper included with this app.": @"使用此应用中随附的 Rex 辅助程序。",
            @"Updates are unavailable in development builds.": @"开发版本无法更新。",
            @"Finish the current update before changing channels.": @"完成当前更新后才能更改频道。",
            @"Preparing Rex": @"正在准备 Rex",
            @"The Rex server is already running.": @"Rex 服务器已在运行。",
            @"A Rex CLI process actor cannot be launched more than once.": @"Rex CLI 进程执行器不能启动多次。",
            @"rex server start failed": @"rex server 启动失败",
            @"Rex returned an invalid start timestamp": @"Rex 返回了无效的启动时间戳",
            @"Rex returned an invalid server endpoint": @"Rex 返回了无效的服务器端点",
            @"Rex returned an unsupported server endpoint scheme": @"Rex 返回了不受支持的服务器端点协议",
            @"Rex returned a Unix socket endpoint in an unsupported format": @"Rex 返回了格式不受支持的 Unix 套接字端点",
            @"Rex returned an invalid Unix socket endpoint": @"Rex 返回了无效的 Unix 套接字端点",
            @"this Rex binary does not provide the required server JSON API": @"此 Rex 二进制文件不提供所需的服务器 JSON API",
            @"Unable to follow Rex server logs:": @"无法跟踪 Rex 服务器日志：",
            @"Unable to observe Rex server status:": @"无法观察 Rex 服务器状态：",
            @"the Rex CLI ended without a status": @"Rex CLI 结束时没有状态",
            @"No Rex launch configuration has been provided.": @"未提供 Rex 启动配置。",
            @"Remove Host": @"移除主机",
            @"Remove “": @"移除“",
            @"”? Removing a host leaves its sessions running on the remote server.": @"”？移除主机会使其会话继续在远程服务器上运行。",
            @"Removing a host leaves its sessions running on the remote server.": @"移除主机会使其会话继续在远程服务器上运行。",
            @"Remove “foo”?": @"移除“foo”？",
            @"Action center": @"操作中心",
            @"Show full message": @"显示完整消息",
            @"Collapse message": @"折叠消息",
            @"No custom themes": @"没有自定义主题",
            @"This tab is open in another window.": @"此标签页已在另一个窗口中打开。",
            @"A theme with this name already exists.": @"已存在同名主题。",
            @"Couldn’t load folders": @"无法加载文件夹",
            @"Couldn't load folders": @"无法加载文件夹",
            @"Couldn’t load": @"无法加载",
            @"Couldn't load": @"无法加载",
            @"You don’t have permission to view": @"你没有权限查看",
            @"You don't have permission to view": @"你没有权限查看",
            @"is not a folder": @"不是文件夹",
            @"No folders named": @"没有名为",
            @"Loading folders": @"正在加载文件夹",
            @"Add Remote Host": @"添加远程主机",
            @"is not an HTTP or HTTPS address": @"不是 HTTP 或 HTTPS 地址",
            @"Type the address of a Rex host": @"输入 Rex 主机地址",
            @"Couldn’t Connect": @"无法连接",
            @"Couldn't Connect": @"无法连接",
            @"Select Interface Style": @"选择界面样式",
            @"Press a shortcut for": @"按下用于",
            @"Choose a Key to Remove It": @"选择要移除的按键",
            @"Reset to Default": @"重置为默认值",
            @"Search actions": @"搜索操作",
            @"Selection Foreground": @"选区前景色",
            @"Selection Background": @"选区背景色",
            @"Set copy on selection": @"设置选择后复制",
            @"Enable Rounded Selection Corners": @"启用选区圆角",
            @"Select Terminal Padding Color": @"选择终端内边距颜色",
            @"Select Update Channel": @"选择更新频道",
            @"Every commit that passes CI. Expect some instability.": @"每个通过 CI 的提交。预计会有不稳定。",
            @"A native notification when terminal programs send notifications.": @"终端程序发送通知时显示系统通知。",
            @"Let programs send native notifications with OSC 9 or OSC 777.": @"允许程序通过 OSC 9 或 OSC 777 发送系统通知。",
            @"A native notification when Rex needs you to sign in to Tailscale.": @"Rex 需要你登录 Tailscale 时显示系统通知。",
            @"A native notification when a tailnet administrator must approve this Mac.": @"Tailscale 网络管理员必须批准此 Mac 时显示系统通知。",
            @"A native notification when Tailscale stops or reports an error.": @"Tailscale 停止或报告错误时显示系统通知。",
            @"A tailnet administrator must approve this device.": @"Tailscale 网络管理员必须批准此设备。",
            @"Open Rex to finish signing in.": @"打开 Rex 以完成登录。",
            @"Retry serving over Tailscale": @"通过 Tailscale 重试共享",
            @"Open Tailscale DNS settings": @"打开 Tailscale DNS 设置",
            @"Sign out and back in to modify tags.": @"退出再重新登录以修改标签。",
            @"Check your account and sign-out progress, configure a hostname and sign in, reopen or cancel enrollment, or sign out.": @"检查账户和退出登录进度，配置主机名并登录，重新打开或取消注册，或退出登录。",
            @"Reopen Tailscale sign-in in your browser": @"在浏览器中重新打开 Tailscale 登录",
            @"Cancel Tailscale sign-in": @"取消 Tailscale 登录",
            @"A newer server is available": @"有更新的服务器可用",
            @"Server and app are incompatible": @"服务器与应用不兼容",
            @"This server requires a newer Rex.app": @"此服务器需要更新版本的 Rex.app",
            @"Server settings have changed": @"服务器设置已更改",
            @"New API features are available": @"有新的 API 功能可用",
            @"Cannot connect to this server": @"无法连接到此服务器",
            @"System permissions": @"系统权限",
            @"Grant System Permissions": @"授予系统权限",
            @"Pane Action Failed": @"窗格操作失败",
            @"The pane action failed.": @"窗格操作失败。",
            @"Terminal Attachment Failed": @"终端附加失败",
            @"Paste Unsafe Text?": @"粘贴不安全文本？",
            @"This paste could run commands before you can review them. Paste it anyway?": @"此粘贴可能会在你查看前运行命令。仍要粘贴吗？",
            @"The terminal stream was interrupted. Reconnecting automatically.": @"终端流已中断。正在自动重新连接。",
            @"The connection dropped. This terminal keeps its contents and continues where it left off.": @"连接已断开。此终端会保留内容并从中断处继续。",
            @"Reconnecting": @"正在重新连接",
            @"Content preserved.": @"内容已保留。",
            @"No match selected": @"未选择匹配项",
            @"Searching, no matches yet": @"正在搜索，尚无匹配项",
            @"Click to resize it to fit this window.": @"点击以调整大小，使其适应此窗口。",
            @"Sized by another client": @"由另一个客户端调整大小",
            @"Rex returned an incomplete pane layout.": @"Rex 返回了不完整的窗格布局。",
            @"The terminal could not be reset.": @"无法重置终端。",
            @"The tab could not be activated.": @"无法激活标签页。",
            @"The session could not be moved.": @"无法移动会话。",
            @"The tab could not be moved.": @"无法移动标签页。",
            @"The tab could not be closed.": @"无法关闭标签页。",
            @"The tab could not be created.": @"无法创建标签页。",
            @"The name could not be changed.": @"无法更改名称。",
            @"The session could not be closed.": @"无法关闭会话。",
            @"The session could not be created.": @"无法创建会话。",
            @"Waiting for the shared server connection to be replaced.": @"正在等待共享服务器连接被替换。",
            @"Preparing Rex Server": @"正在准备 Rex 服务器",
            @"Waiting for the local control API to become available.": @"正在等待本地控制 API 可用。",
            @"Stopping Rex Server": @"正在停止 Rex 服务器",
            @"Starting Rex Server": @"正在启动 Rex 服务器",
            @"Rex Server Is Unavailable": @"Rex 服务器不可用",
            @"Rex Server Is Stopped": @"Rex 服务器已停止",
            @"Restart the server to use new features": @"重新启动服务器以使用新功能",
            @"The running Rex server is incompatible with this version of Rex.app.": @"正在运行的 Rex 服务器与此版本的 Rex.app 不兼容。",
            @"Restart is required.": @"需要重新启动。",
            @"Restart the Rex server?": @"重新启动 Rex 服务器？",
            @"This needs the newer server. Restart it and try again.": @"需要使用更新的服务器。请重新启动后重试。",
            @"Restart Rex Server": @"重新启动 Rex 服务器",
            @"Rex.app Can’t Talk to the Server": @"Rex.app 无法与服务器通信",
            @"Rex.app Can't Talk to the Server": @"Rex.app 无法与服务器通信",
            @"Rex.app Is Older Than the Server": @"Rex.app 版本低于服务器",
            @"The Rex Server Needs a Restart": @"Rex 服务器需要重新启动",
            @"No attached clients": @"没有附加客户端",
            @"Select a session": @"选择会话",
            @"Inspect the hub's servers and sessions in the main diagnostics view.": @"在主诊断视图中检查 Hub 的服务器和会话。",
            @"Working Directory": @"工作目录",
            @"Copy launch command": @"复制启动命令",
            @"Copy server build commit": @"复制服务器构建提交",
            @"Copy server build version": @"复制服务器构建版本",
            @"Connection details are available when the server is ready.": @"服务器就绪后即可查看连接详情。",
            @"Waiting for server": @"正在等待服务器",
            @"Not available until the server is ready": @"服务器就绪前不可用",
            @"Tailscale stopped": @"Tailscale 已停止",
            @"Approve this device in Tailscale": @"在 Tailscale 中批准此设备",
            @"Tailscale assigned": @"Tailscale 已分配",
            @"The Tailscale request timed out. Try again.": @"Tailscale 请求超时。请重试。",
            @"Tailscale is taking longer than usual. You can keep waiting or cancel.": @"Tailscale 所需时间比平时长。你可以继续等待或取消。",
            @"Taking longer than usual. If you’ve finished in your browser, Rex is still waiting for Tailscale to confirm.": @"所需时间比平时长。如果你已在浏览器中完成操作，Rex 仍在等待 Tailscale 确认。",
            @"Taking longer than usual. If you've finished in your browser, Rex is still waiting for Tailscale to confirm.": @"所需时间比平时长。如果你已在浏览器中完成操作，Rex 仍在等待 Tailscale 确认。",
            @"Update Channel Tagged builds for testers.": @"更新频道 供测试人员使用的标记版本。",
            @"Local API URL unix:///Users/a1/Library/Application Support/rex/server.sock": @"本地 API URL unix:///Users/a1/Library/Application Support/rex/server.sock",
            @"Find in Scrollback": @"在回滚中查找",
            @"Session View Failed": @"会话视图失败",
            @"Loading the window's blocks": @"正在加载窗口块",
            @"Loading the window’s blocks": @"正在加载窗口块",
            @"Keyboard shortcut: ": @"键盘快捷键：",
            @"Open a new tab to start a terminal.": @"打开新标签页以启动终端。",
            @"Choose to try again.": @"选择重试。",
            @"The connection dropped. Sessions stay open while Rex reconnects.": @"连接已断开。Rex 重新连接期间会话保持打开。",
            @"The remote host couldn't be added.": @"远程主机添加失败。",
            @"The remote host couldn’t be added.": @"远程主机添加失败。",
            @"The remote host couldn't be updated.": @"远程主机更新失败。",
            @"The remote host couldn’t be updated.": @"远程主机更新失败。",
            @"Enter a host name.": @"输入主机名。",
            @"Enter an HTTP or HTTPS URL, or a bare hostname and port.": @"输入 HTTP 或 HTTPS URL，或直接输入主机名和端口。",
            @"That remote host is already saved.": @"该远程主机已保存。",
            @"Rex connects to the address and saves it on this Mac.": @"Rex 会连接到该地址，并将其保存在此 Mac 上。",
            @"Preview unavailable": @"预览不可用",
            @"Couldn’t import theme": @"无法导入主题",
            @"Couldn't import theme": @"无法导入主题",
            @"The theme file could not be read.": @"无法读取主题文件。",
            @"The theme file couldn’t be read.": @"无法读取主题文件。",
            @"This removes the custom theme and any unsaved edits to it. If selected, Rex returns to the default theme.": @"这将移除自定义主题及其未保存的编辑。选择后，Rex 将恢复为默认主题。",
            @"The current Theme Customizer draft has changes that haven't been saved.": @"当前主题自定义器草稿有未保存的更改。",
            @"The current Theme Customizer draft has changes that haven’t been saved.": @"当前主题自定义器草稿有未保存的更改。",
            @"No trusted links": @"没有受信任的链接",
            @"Choosing Always Open on a link's notice adds the link's scheme and the app that opens it here.": @"在链接提示中选择“始终打开”后，链接协议和打开它的应用会显示在此处。",
            @"Choosing Always Open on a link’s notice adds the link’s scheme and the app that opens it here.": @"在链接提示中选择“始终打开”后，链接协议和打开它的应用会显示在此处。",
            @"These apply only while Links that open apps is set to Ask First.": @"这些设置仅在“打开应用的链接”设为“先询问”时生效。",
            @"Links with that scheme open without asking until you remove them.": @"使用该协议的链接会直接打开，直到你将其移除。",
            @"Connection warning": @"连接警告",
            @"No processes are reporting activity": @"没有进程报告活动",
            @"Opening terminal": @"正在打开终端",
            @"Links that open other apps need confirmation.": @"打开其他应用的链接需要确认。",
            @"No app is set to open ": @"没有设置用于打开的应用：",
            @"Rex is set to never open links that launch other apps.": @"Rex 已设置为永不打开会启动其他应用的链接。",
            @"Unsupported Terminal": @"不受支持的终端",
            @"Rex needs attention": @"Rex 需要注意",
            @"Tailscale needs attention": @"Tailscale 需要注意",
            @"Rex server running": @"Rex 服务器正在运行",
            @"Rex server stopped": @"Rex 服务器已停止",
            @"Your device must be connected to the same Tailscale network.": @"你的设备必须连接到同一 Tailscale 网络。",
            @"Tap \"Pair via QR Code\" in Rex on your other device.": @"在另一台设备上的 Rex 中点击“通过二维码配对”。",
            @"Restart Required": @"需要重新启动",
            @"Preparing server...": @"正在准备服务器…",
            @"Preparing server…": @"正在准备服务器…",
            @"Teaches agents to drive Rex: sessions, panes, and config.": @"教会智能体操作 Rex：会话、窗格和配置。",
            @"Lets agents open protected folders and record the screen.": @"允许智能体打开受保护文件夹并录制屏幕。",
            @"Runs rex skill setup for every agent on this Mac.": @"为此 Mac 上的每个智能体运行 rex 技能设置。",
            @"Paste this prompt into an agent to migrate your config.": @"将此提示粘贴到智能体中以迁移你的配置。",
            @"Couldn’t load files": @"无法加载文件",
            @"Couldn't load files": @"无法加载文件",
            @"Couldn’t load this folder (": @"无法加载此文件夹（",
            @"Couldn't load this folder (": @"无法加载此文件夹（",
            @"You don’t have permission to view this folder": @"你没有权限查看此文件夹",
            @"You don't have permission to view this folder": @"你没有权限查看此文件夹",
            @"Rex Server is running as part of ": @"Rex 服务器属于 ",
            @"Rex server is running as part of ": @"Rex 服务器属于 ",
            @"Choose how Rex.app receives updates when Developer Mode is enabled.": @"选择在启用开发者模式时 Rex.app 接收更新的方式。",
            @"Choose how terminal tabs and pane headers are named.": @"选择终端标签页和窗格标题的命名方式。",
            @"Choose how this Mac appears to Rex servers and the command line.": @"选择此 Mac 在 Rex 服务器和命令行中的显示方式。",
            @"Choose tab placement, sizing, and pane icon counts and colors.": @"选择标签页位置、大小以及窗格图标的数量和颜色。",
            @"Choose the color scheme, interface materials, and theme tint.": @"选择配色方案、界面材质和主题着色。",
            @"Choose the command run when a new local terminal opens.": @"选择打开新的本地终端时运行的命令。",
            @"Choose the fill color behind selected text.": @"选择选中文本背后的填充颜色。",
            @"Choose the folder containing the Rex source checkout.": @"选择包含 Rex 源代码检出的文件夹。",
            @"Choose the included server or run Rex from a source checkout.": @"选择使用随附服务器，或从源代码检出运行 Rex。",
            @"Choose the text color inside a selection.": @"选择选区内的文本颜色。",
            @"Choose whether Rex opens workspace windows at startup.": @"选择 Rex 是否在启动时打开工作区窗口。",
            @"Choose whether terminal links that launch other apps ask first.": @"选择打开其他应用的终端链接是否先询问。",
            @"Choose whether terminal programs can send native macOS notifications, and see the ones Rex sends for Tailscale.": @"选择终端程序是否可以发送 macOS 原生通知，并查看 Rex 为 Tailscale 发送的通知。",
            @"Choose whether the Option key sends Alt or types special characters.": @"选择 Option 键发送 Alt 还是输入特殊字符。",
            @"Click a position in the window diagram to place notifications at the top or bottom, aligned left, center, or right.": @"点击窗口示意图中的位置，将通知放在顶部或底部，并向左、居中或向右对齐。",
            @"Control terminal text colors and readability.": @"控制终端文本颜色和可读性。",
            @"Control the color drawn around terminal cells.": @"控制终端单元格周围绘制的颜色。",
            @"Customize Rex's app icon and Dock and menu bar icon visibility.": @"自定义 Rex 的应用图标，以及程序坞和菜单栏图标的显示方式。",
            @"Enable or disable access to Rex over your tailnet.": @"启用或禁用通过 tailnet 访问 Rex。",
            @"Enter a browser origin or wildcard subdomain to allow after restarting Rex.": @"输入重启 Rex 后允许的浏览器来源或通配子域名。",
            @"Focus a pane by moving the pointer over it, without clicking.": @"将指针移到窗格上即可聚焦，无需点击。",
            @"Give your theme a name.": @"为主题命名。",
            @"Keep tabs whose programs report that they're idle in the Activity filter and popup, even after you've seen them.": @"即使已查看过，也要在活动筛选器和弹出菜单中保留程序报告为空闲的标签页。",
            @"Select a live Auto, Light, or Dark material preview. Auto follows the system appearance.": @"选择实时的自动、浅色或深色材质预览。自动会跟随系统外观。",
            @"Show the keys that can come next after the first key of a sequence, such as a tmux-style prefix.": @"显示序列第一个按键之后可能出现的按键，例如 tmux 样式的前缀。",
            @"This app can't perform actions from other clients yet.": @"此应用暂时无法执行其他客户端的操作。",
            @"This host uses Tailscale. Check that Tailscale is connected on this device and the host, and that Rex is running on the host, then retry.": @"此主机使用 Tailscale。请检查此设备和主机上的 Tailscale 是否已连接，并确认主机上的 Rex 正在运行，然后重试。",
            @"This path is not executable on this Mac.": @"此路径在此 Mac 上不可执行。",
            @"This server was already running, so its launch settings are unknown. The selected settings apply after an explicit restart.": @"此服务器已经在运行，因此其启动设置未知。所选设置将在明确重启后生效。",
            @"This server was merged into an existing saved server.": @"此服务器已合并到现有的已保存服务器中。",
            @"Waiting for a password": @"正在等待密码",
            @"Waiting for an answer": @"正在等待答复",
            @"Waiting for the shared Rex server to stop by itself": @"正在等待共享 Rex 服务器自行停止",
            @"The running server and this Rex.app share no version of the control API. Update Rex.app, or restart the server to use the included one.": @"正在运行的服务器与此 Rex.app 没有共同的控制 API 版本。请更新 Rex.app，或重启服务器以使用随附版本。",
            @"The running server is older than this Rex.app. Restart it to use the included server.": @"正在运行的服务器版本低于此 Rex.app。请重启它以使用随附服务器。",
            @"Automatically copy selected terminal text to the clipboard.": @"自动将选中的终端文本复制到剪贴板。",
            @"Automatically open workspace windows when Rex launches.": @"Rex 启动时自动打开工作区窗口。",
            @"Available with the Glass interface style: add glass to panes alongside window and tab materials.": @"仅适用于玻璃界面样式：在窗口和标签页材质之外为窗格添加玻璃效果。",
            @"Every shortcut you recorded or removed in this app goes back to its default. Shortcuts from your configuration file are not affected.": @"你在此应用中记录或移除的所有快捷键都会恢复为默认值。配置文件中的快捷键不受影响。",
            @"Add or remove space between terminal lines.": @"在终端行之间添加或移除间距。",
            @"Adjust low-contrast text against its background; included when using the theme palette.": @"根据背景调整低对比度文本；使用主题调色板时会自动启用。",
            @"Agents can control Rex, including migrating your config from tmux, Ghostty, Herdr, and more": @"智能体可以控制 Rex，包括从 tmux、Ghostty、Herdr 等迁移配置。",
            @"Agents label the session after the task they're working on": @"智能体会根据正在处理的任务为会话命名。",
            @"Ask before, always, or never open links such as ssh:// that launch another app.": @"打开会启动其他应用的 ssh:// 等链接时，可选择先询问、始终打开或永不打开。",
            @"Automatically regenerate palette": @"自动重新生成调色板",
            @"Bring over your setup": @"迁移你的设置",
            @"Bring over your setup from": @"从以下位置迁移你的设置：",
            @"Choose a block, bar, or underline cursor.": @"选择块状、条状或下划线光标。",
            @"Closes the focused pane, else the selected tab, else the window.": @"关闭聚焦窗格，否则关闭选中的标签页，再否则关闭窗口。",
            @"Copies a report of the app, system, server, and host state to the clipboard.": @"将应用、系统、服务器和主机状态报告复制到剪贴板。",
            @"Copies the app and server versions to the clipboard.": @"将应用和服务器版本复制到剪贴板。",
            @"Copies the focused pane's block ID to the clipboard.": @"将聚焦窗格的块 ID 复制到剪贴板。",
            @"Copy full path": @"复制完整路径",
            @"Enter a display name for the icon.": @"输入图标的显示名称。",
            @"Enter a Rex API method.": @"输入 Rex API 方法。",
            @"Evenly resize a tab's panes whenever a pane is created or closed.": @"创建或关闭窗格时均匀调整标签页窗格大小。",
            @"Exits when empty": @"为空时退出",
            @"How far to move the divider, as a percentage of the split it divides. The default is 5.": @"分隔线移动距离，占其所在分栏的百分比。默认值为 5。",
            @"Let Agents Control Rex": @"允许智能体控制 Rex",
            @"Let agents label the session after the task they're working on. Shown while Integrate with available agents is on.": @"允许智能体根据正在处理的任务为会话命名。启用“与可用智能体集成”时显示。",
            @"Let your agents control Rex": @"允许你的智能体控制 Rex",
            @"List the paths you chose most recently first, shared by every session on a host.": @"按最近选择的顺序列出路径；同一主机上的所有会话共享此列表。",
            @"Name this Mac in client lists and for targeting it from rex commands.": @"为此 Mac 设置在客户端列表中的名称，并用于 rex 命令定位。",
            @"Preview and adjust the terminal cursor shape and blinking.": @"预览并调整终端光标形状和闪烁。",
            @"Preview and choose the terminal font, size, style, weight, smoothing, and fallback fonts.": @"预览并选择终端字体、大小、样式、字重、平滑和备用字体。",
            @"Preview Glass or Classic materials with the current theme tint and select a surface style.": @"使用当前主题着色预览玻璃或经典材质，并选择表面样式。",
            @"Preview selection colors and corners, and customize copying with its animation.": @"预览选区颜色和圆角，并自定义带动画的复制效果。",
            @"Programs in any terminal can open apps without asking.": @"任何终端中的程序都可以直接打开应用，无需询问。",
            @"Search every action and the keys bound to it, and record, remove, or reset shortcuts.": @"搜索所有操作及其绑定的按键，并记录、移除或重置快捷键。",
            @"Show idle processes": @"显示空闲进程",
            @"Show key sequence hints and choose how modifier keys behave in terminal input.": @"显示按键序列提示，并选择修饰键在终端输入中的行为。",
            @"Show Rex's icon in the Dock and menu bar, the Dock only, or the menu bar only.": @"选择在程序坞和菜单栏、仅程序坞或仅菜单栏中显示 Rex 图标。",
            @"Show up to three pane icons in vertical tabs.": @"在纵向标签页中最多显示三个窗格图标。",
            @"Show working dots, progress pies, and needs-attention dots and messages on tabs when a program in them reports its status.": @"当标签页中的程序报告状态时，在标签页上显示工作圆点、进度饼图以及需要注意的圆点和消息。",
            @"Use the server included with Rex.app or a local source checkout.": @"使用 Rex.app 随附的服务器或本地源代码检出。",
            @"Welcome to Rex": @"欢迎使用 Rex",
            @"Update this app.": @"更新此应用。",
            @"View and copy the local server endpoint when Developer Mode is enabled.": @"启用开发者模式时查看并复制本地服务器端点。",
            @"View and copy the included server version under Show Details.": @"在“显示详情”下查看并复制随附服务器版本。",
            @"View and copy the source commit of the included server under Show Details.": @"在“显示详情”下查看并复制随附服务器的源代码提交。",
            @"View and copy the included server checksum under Show Details.": @"在“显示详情”下查看并复制随附服务器校验和。",

            @"Choose Preview or Bleeding Edge updates when Developer Mode is enabled.": @"启用开发者模式时选择预览版或前沿版更新。",
            @"Choose this Mac": @"选择此 Mac",
            @"Choose what Insert Path lists when it types a path at the cursor.": @"选择“插入路径”在光标处输入路径时列出的内容。",
            @"Choose what Rex tells coding agents running in its terminals.": @"选择 Rex 告诉其终端中运行的编码智能体的内容。",
            @"Choose where floating notifications appear in the window.": @"选择浮动通知在窗口中的位置。",
            @"Check whether the selected Rex installation is ready to run.": @"检查所选 Rex 安装是否已准备好运行。",
            @"Fades content in every pane when its window is inactive.": @"窗口处于非活动状态时淡化每个窗格中的内容。",
            @"Keeps the window width unchanged when showing or hiding the sidebar. Full-screen and maximized windows always keep their width.": @"显示或隐藏侧边栏时保持窗口宽度不变。全屏和最大化窗口始终保持其宽度。",
            @"Let agents name sessions": @"允许智能体命名会话",
            @"Move Session Down": @"向下移动会话",
            @"No Results": @"无结果",
            @"Open Config File": @"打开配置文件",
            @"Open Diagnostics": @"打开诊断",
            @"Open the containing settings group": @"打开包含此项的设置组",
            @"Opening Diagnostics from a Rex URL": @"正在从 Rex URL 打开诊断",
            @"Opening Settings from a Rex URL": @"正在从 Rex URL 打开设置",
            @"Opening this local target could execute code.": @"打开此本地目标可能会执行代码。",
            @"Opens Trusted Links settings": @"打开受信任的链接设置",
            @"Pane background colors ignore the theme when Glass is active.": @"启用玻璃样式时，窗格背景颜色不使用主题。",
            @"Preparing a new session for this window.": @"正在为此窗口准备新会话。",
            @"Preparing the local server connection.": @"正在准备本地服务器连接。",
            @"Select Source Checkout in Settings to run Rex.": @"在设置中选择“源代码检出”以运行 Rex。",
            @"Select the theme palette used in dark appearance.": @"选择深色外观使用的主题调色板。",
            @"Select the theme palette used in light appearance.": @"选择浅色外观使用的主题调色板。",
            @"Sessions will become available after the server starts again.": @"服务器再次启动后会话将恢复可用。",
            @"Source checkout ready": @"源代码检出已就绪",
            @"Source checkout unavailable": @"源代码检出不可用",
            @"Starting Rex server": @"正在启动 Rex 服务器",
            @"Stopping Rex server": @"正在停止 Rex 服务器",
            @"Starting the server from a Rex URL": @"正在从 Rex URL 启动服务器",
            @"Stopping the server from a Rex URL": @"正在从 Rex URL 停止服务器",
            @"Stops the local Rex server and starts it again.": @"停止本地 Rex 服务器并重新启动。",
            @"Turn on Badge Dock icon under Program Activity to count this status.": @"在“程序活动”中打开“程序坞标记”以统计此状态。",
            @"Turn on Play sounds under Program Activity to hear this status.": @"在“程序活动”中打开“播放声音”以听到此状态。",
            @"Turn on Show system notifications and Badge Dock icon under Program Activity to use these.": @"在“程序活动”中打开“显示系统通知”和“程序坞标记”以使用这些功能。",
            @"Turn on Show system notifications under Program Activity to get notifications.": @"在“程序活动”中打开“显示系统通知”以接收通知。",
            @"Update Rex on the server.": @"更新服务器上的 Rex。",
            @"Update the server to a version of Rex that supports revision": @"将服务器更新到支持该修订版的 Rex 版本",
            @"Use glass for panes": @"对窗格使用玻璃效果",
            @"The copied text expired before Rex could read it.": @"复制的文本在 Rex 读取前已过期。",
            @"The server connection changed before the operation completed.": @"操作完成前服务器连接已发生变化。",
            @"The session is no longer available.": @"会话已不再可用。",
            @"The target contains invisible or line-breaking characters.": @"目标包含不可见字符或换行字符。",
            @"The target may be a file on another host.": @"目标可能是另一台主机上的文件。",
            @"The window presentation ended before the request was made.": @"窗口展示在发出请求前已结束。",
            @"Update available": @"有可用更新",
            @"Updater configured": @"更新器已配置",
            @"No server output yet.": @"暂时没有服务器输出。",
            @"No connection is ready.": @"没有可用的连接。",
            @"Preparing Session": @"正在准备会话",
            @"Session Creation Failed": @"会话创建失败",
            @"Rex server exited": @"Rex 服务器已退出",
            @"Rex server failed": @"Rex 服务器失败",
            @"Rex server unavailable": @"Rex 服务器不可用",
            @"Rex server was stopped": @"Rex 服务器已停止",
            @"Rex server restart required": @"Rex 服务器需要重新启动",
            @"Rex for iOS cannot take actions yet.": @"Rex for iOS 目前还不能执行操作。",
            @"This build of Rex.app does not include": @"此 Rex.app 构建不包含",
            @"This version of Rex can": @"此版本的 Rex 可以",
            @"Restarting shared Rex server": @"正在重新启动共享 Rex 服务器",
            @"restart required": @"需要重新启动",
            @"restart recommended": @"建议重新启动",
            @"The build completed without producing an executable": @"构建完成但没有生成可执行文件",
            @"The build exited with status": @"构建以以下状态退出",
            @"The checkout directory does not exist": @"检出目录不存在",
            @"The local target does not exist or is not a regular file or directory.": @"本地目标不存在，或不是普通文件或目录。",

            @"Type a new session name": @"输入新的会话名称",
            @"Leave the name empty to restore the default.": @"留空以恢复默认名称。",
            @"Restore Default Title": @"恢复默认标题",
            @"Recently used path. Press ": @"最近使用的路径。按下 ",
            @" to remove from recents.": @" 从最近记录中移除。",
            @"Couldn't update coding agents": @"无法更新编码智能体",
            @"Fade content for inactive windows": @"淡化非活动窗口中的内容",
            @"Glass panes manage their own inactive window appearance": @"玻璃窗格具有独立的非活动窗口外观",
            @"Installs a Rex skill and session hooks for supported agents.": @"为受支持的智能体安装 Rex 技能和会话钩子。",
            @"Split a tab with more than one active pane into a row for each pane in the Activity filter and popup. Clicking a row focuses its pane.": @"将包含多个活动窗格的标签页拆分为“活动”筛选器和弹出面板中的逐窗格行。点击某行即可聚焦对应窗格。",
            @"Send a macOS notification when a program reports a status while Rex is in the background, independently of tab indicators. Clicking it opens the program's tab.": @"当 Rex 在后台时，程序报告状态会单独发送 macOS 通知，不受标签页指示器影响。点击通知可打开程序所在的标签页。",
            @"See whether the local server is running and for how long, with version and API details in its info popover.": @"查看本地服务器是否运行及运行时长，并在信息弹出面板中查看版本和 API 详情。",
            @"When an update, compatibility issue, or pending settings change is detected, see the discrepancy and restart the server when appropriate.": @"检测到更新、兼容性问题或待处理的设置更改时，查看差异并在适当时重新启动服务器。",
            @"Serve over Tailscale": @"通过 Tailscale 提供服务",
            @"Limit access to your Tailscale account": @"限制为你的 Tailscale 账户访问",
            @"See this device": @"查看此设备",
            @"Place tabs Above, on the Left Side, or on the Right Side of the window.": @"将标签页放在窗口上方、左侧或右侧。",
            @"Use theme accent": @"使用主题强调色",
            @"Show zero to three pane icons in vertical tabs, or up to five in horizontal tabs.": @"在纵向标签页中显示零到三个窗格图标，在横向标签页中最多显示五个。",
            @"Keep window width": @"保持窗口宽度",
            @"Preserve window width": @"保留窗口宽度",
            @"Fixed window width": @"固定窗口宽度",
            @"Keep window size": @"保持窗口大小",
            @"Color a pane and its header with the background a full-screen program paints.": @"使用全屏程序绘制的背景为窗格及其标题着色。",
            @"Fade unfocused pane surfaces, content, both, or neither.": @"淡化未聚焦窗格的表面、内容、两者或都不淡化。",
            @"fade inactive pane content": @"淡化非活动窗格内容",
            @"Fade inactive windows while respecting the pane fade choice. Glass content fades equally in every pane.": @"遵循窗格淡化选项淡化非活动窗口。玻璃内容会在每个窗格中等量淡化。",
            @"Draw an accent-colored border around the focused pane that follows focus.": @"在聚焦窗格周围绘制随焦点移动的强调色边框。",
            @"Choose Default": @"选择默认",
            @"Dynamic, Bright, or Twilight artwork for the app icon.": @"为应用图标选择动态、明亮或暮色图案。",
            @"Edit light theme": @"编辑浅色主题",
            @"Customize light theme": @"自定义浅色主题",
            @"Duplicate light theme": @"复制浅色主题",
            @"Fork light theme": @"派生浅色主题",
            @"Delete light theme": @"删除浅色主题",
            @"theme customizer": @"主题自定义器",
            @"Theme customizer": @"主题自定义器",
            @"Use the theme": @"使用此主题",
            @"Customize dark theme": @"自定义深色主题",
            @"Duplicate dark theme": @"复制深色主题",
            @"Delete dark theme": @"删除深色主题",
            @"Map RGB and extended text colors to the nearest theme color, then correct contrast.": @"将 RGB 和扩展文本颜色映射到最接近的主题颜色，然后校正对比度。",
            @"force theme colors": @"强制使用主题颜色",
            @"Force theme colors": @"强制使用主题颜色",
            @"Read theme and program colors as Display P3, like Ghostty's window-colorspace.": @"像 Ghostty 的 window-colorspace 一样，以 Display P3 读取主题和程序颜色。",
            @"Shine across the selection to confirm each copy.": @"复制后在选区上播放闪烁动画以确认。",
            @"Review and remove the links you chose to always open, once Always Open adds one.": @"查看并移除你选择始终打开的链接；选择“始终打开”后，链接会显示在此处。",
            @"Set the executable and arguments, or leave empty for the default login shell.": @"设置可执行文件和参数，或留空以使用默认登录 Shell。",
            @"shortcut search field": @"快捷键搜索框",
            @"remote host status": @"远程主机状态",
            @"remote host reconnect": @"重新连接远程主机",
            @"Reveal settings for development and debugging.": @"显示用于开发和调试的设置。",
            @"Inspect the local server's API endpoint when Developer Mode is enabled.": @"启用开发者模式后查看本地服务器的 API 端点。",
            @"copy local endpoint": @"复制本地端点",
            @"Review the permitted origins and remove custom entries.": @"查看允许的来源并移除自定义条目。",
            @"Configuration menu": @"配置菜单",
            @"configuration file": @"配置文件",
            @"restore defaults": @"恢复默认值",
            @"Copy the path of the init.lua file where you write key bindings, copy the shortcuts you changed in the app as Lua, or reset them all.": @"复制用于编写按键绑定的 init.lua 文件路径，将在应用中更改的快捷键复制为 Lua，或全部重置。",
            @"Reset all shortcuts recorded here?": @"重置此处记录的所有快捷键？",
            @"Your configuration file doesn’t declare this mode, so nothing can enter it.": @"配置文件没有声明此模式，因此没有任何内容可以进入该模式。",
            @"Your configuration file doesn't declare this mode, so nothing can enter it.": @"配置文件没有声明此模式，因此没有任何内容可以进入该模式。",
            @"Removed in the app. Reset brings it back.": @"已在应用中移除。重置后会恢复。",
            @"Executable and arguments. Use quotes to group arguments. Applies to new terminals on this Mac. Remote hosts use their own default shell. New tabs and splits use the source terminal's working directory when available. Otherwise, they use the server's default directory.": @"可执行文件和参数。使用引号将参数分组。适用于此 Mac 上的新终端。远程主机使用自己的默认 Shell。新标签页和分栏可用时使用源终端的工作目录，否则使用服务器的默认目录。",
            @"The current Theme Customizer draft has changes that haven't been saved. Discard them?": @"当前主题自定义器草稿有未保存的更改。要放弃这些更改吗？",
            @"The current Theme Customizer draft has changes that haven’t been saved. Discard them?": @"当前主题自定义器草稿有未保存的更改。要放弃这些更改吗？",
            @"New Local Session": @"新建本地会话",
            @"Expected a UTF-8 Ghostty theme or an iTerm color file.": @"需要 UTF-8 Ghostty 主题或 iTerm 颜色文件。",
            @"Regenerates the extended color palette from the base theme.": @"根据基础主题重新生成扩展调色板。",
            @"Enable this to make changes to the base theme colors and the ANSI Standard palette automatically update the extended palette.": @"启用后，基础主题颜色和 ANSI 标准调色板的更改会自动更新扩展调色板。",
            @"Changes to the base theme colors and the ANSI Standard palette will automatically update the extended palette.": @"基础主题颜色和 ANSI 标准调色板的更改会自动更新扩展调色板。",
            @"Reset Overrides": @"重置覆盖",
            @"Untitled Dark Theme": @"未命名深色主题",
            @"Regenerate Palette": @"重新生成调色板",
            @"Restore the palette and name from the start of this editing session or your last save.": @"恢复本次编辑会话开始时或上次保存时的调色板和名称。",
            @"Update the sheet": @"更新面板",
            @"The tab's window is unavailable for capture.": @"标签页所在窗口不可用于捕获。",
            @"The tab’s window is unavailable for capture.": @"标签页所在窗口不可用于捕获。",
            @"Restart Server": @"重启服务器",
            @"Rex.app couldn't read the running server's reply while connecting. Restarting the server may fix it, but you will lose your active sessions.": @"Rex.app 连接时无法读取运行中服务器的响应。重新启动服务器可能会修复问题，但会丢失活动会话。",
            @"Connect to the Rex Server": @"连接到 Rex 服务器",
            @"Start the local Rex server to list and create sessions.": @"启动本地 Rex 服务器以列出并创建会话。",
            @"Enable Tailscale and wait for HTTPS to be ready in Rex Server settings to pair a device.": @"在 Rex 服务器设置中启用 Tailscale，并等待 HTTPS 就绪后配对设备。",
            @"Rex skill setup": @"Rex 技能设置",
            @"Pair Device": @"配对设备",
            @"use theme accent": @"使用主题强调色",
            @"keep window width": @"保持窗口宽度",
            @"preserve window width": @"保留窗口宽度",
            @"fixed window width": @"固定窗口宽度",
            @"keep window size": @"保持窗口大小",
            @"fade panes in inactive windows": @"淡化非活动窗口中的窗格",
            @"use pane fade choice": @"使用窗格淡化选项",
            @"fade content for inactive windows": @"淡化非活动窗口中的内容",
            @"show menu bar icon": @"显示菜单栏图标",
            @"show window on launch": @"启动时显示窗口",
            @"open window on startup": @"启动时打开窗口",
            @"edit light theme": @"编辑浅色主题",
            @"customize light theme": @"自定义浅色主题",
            @"duplicate light theme": @"复制浅色主题",
            @"fork light theme": @"派生浅色主题",
            @"delete light theme": @"删除浅色主题",
            @"customize dark theme": @"自定义深色主题",
            @"duplicate dark theme": @"复制深色主题",
            @"delete dark theme": @"删除深色主题",
            @"force theme colours": @"强制使用主题颜色",
            @"Join characters like -> and != into single symbols.": @"将 ->、!= 等字符组合为单个符号。",
            @"Selection foreground": @"选区前景色",
            @"Selection background": @"选区背景色",
            @"Source Directory": @"源代码目录",
            @"Installation status": @"安装状态",
            @"Apply the selected theme's colors to interface surfaces.": @"将所选主题的颜色应用于界面表面。",
            @"Requires Developer Mode": @"需要开发者模式",
            @"Check the command": @"检查命令",
            @"Line height adjustment in percent": @"行高调整百分比",
            @"Hide extended palette": @"隐藏扩展调色板",
            @"Included Rex unavailable": @"随附的 Rex 不可用",
            @"Included Rex ready": @"随附的 Rex 已就绪",
            @"Local Go toolchain": @"本地 Go 工具链",
            @"Nix development shell": @"Nix 开发 Shell",
            @"Renderer Unavailable": @"渲染器不可用",
            @"Setup finished without updating": @"设置完成但未更新",
            @"HTTPS status unknown": @"HTTPS 状态未知",
            @"Show menu bar icon": @"显示菜单栏图标",
            @"Choose a theme and tab style": @"选择主题和标签页样式",
            @"Pick a theme and tab style": @"选择主题和标签页样式",
            @"The included Rex helper could not report its version: ": @"随附的 Rex 辅助程序无法报告其版本：",
            @"The included Rex helper returned invalid version JSON.": @"随附的 Rex 辅助程序返回了无效的版本 JSON。",
            @"The included Rex helper did not report a full 40-character release commit.": @"随附的 Rex 辅助程序没有报告完整的 40 字符发布提交。",
            @"The included Rex helper reported an empty version.": @"随附的 Rex 辅助程序报告的版本为空。",
            @"The included Rex helper returned more than 64 KiB of version output.": @"随附的 Rex 辅助程序返回了超过 64 KiB 的版本输出。",
            @"The included Rex helper did not answer its version check within five seconds.": @"随附的 Rex 辅助程序未在五秒内回应版本检查。",
            @"The included Rex helper could not be inspected: ": @"无法检查随附的 Rex 辅助程序：",
            @"The Rex source checkout could not be built: ": @"无法构建 Rex 源代码检出：",
            @"The Rex source checkout requires an executable ": @"Rex 源代码检出需要可执行文件 ",
            @"The Rex source checkout is invalid: ": @"Rex 源代码检出无效：",
            @"Request JSON is invalid: ": @"请求 JSON 无效：",
            @"This build of Rex.app does not include ": @"此版本的 Rex.app 不包含 ",
            @"This needs the newer server. Restart it and try again. ": @"此功能需要更新的服务器。请重启服务器后重试。",
            @"Sends one key to the focused terminal, as if it had been pressed there.": @"向聚焦的终端发送一个按键，就像在那里按下该按键一样。",
            @"Sets the time between cursor blinks in milliseconds when Blink speed is Custom.": @"当闪烁速度为“自定义”时，以毫秒为单位设置光标闪烁间隔。",
            @"Service Unavailable": @"服务不可用",
            @"The target is not a valid link.": @"目标不是有效链接。",
            @"The web target does not contain a valid host.": @"网页目标不包含有效主机。",
            @"A Rex server locator cannot be empty.": @"Rex 服务器地址不能为空。",
            @"A Rex server locator cannot contain a user or password.": @"Rex 服务器地址不能包含用户名或密码。",
            @"A Rex server locator cannot contain whitespace.": @"Rex 服务器地址不能包含空白字符。",
            @"A Rex server locator requires a host.": @"Rex 服务器地址必须包含主机。",
            @"A server record requires at least one locator.": @"服务器记录至少需要一个地址。",
            @"A window in the session to show. If omitted, the session opens as usual.": @"要显示的会话窗口。省略后，会话将按通常方式打开。",
            @"Absolute path of a Ghostty theme or iTerm color file on this machine.": @"此 Mac 上 Ghostty 主题或 iTerm 颜色文件的绝对路径。",
            @"Changing Tailscale tags timed out. Check the status, then try again.": @"更改 Tailscale 标签超时。请检查状态后重试。",
            @"Continue from the opposite edge of the layout when no pane lies in the direction. The default is true.": @"当该方向没有窗格时，从布局的另一侧继续。默认开启。",
            @"Don't rename the Rex session; it's the onboarding walkthrough's session.": @"不要重命名 Rex 会话；这是入门流程使用的会话。",
            @"Expected a UTF-8 Ghostty theme or iTerm color file.": @"需要 UTF-8 Ghostty 主题或 iTerm 颜色文件。",
            @"Imports a Ghostty theme or iTerm color file and selects it.": @"导入 Ghostty 主题或 iTerm 颜色文件并选中它。",
            @"Keep holding, and press the key for the shortcut.": @"继续按住，然后按下快捷键对应的按键。",
            @"Leave the mode after one of its own keys performs. The default is false.": @"在模式自身的某个按键执行后退出模式。默认关闭。",
            @"Makes the keys a mode binds perform, until the mode is left.": @"让模式绑定的按键执行其操作，直到退出模式。",
            @"Rex turned off tailnet serving. Check the server log, then retry.": @"Rex 已关闭 tailnet 服务。请检查服务器日志后重试。",
            @"Rex will verify the caller is signed in to your Tailscale account.": @"Rex 将验证调用者是否已登录 Tailscale 账户。",
            @"Saved. These apply when the Rex server is reachable.": @"已保存。Rex 服务器可访问时这些设置才会生效。",
            @"Sends the key that performed it to the focused terminal, for a script to answer.": @"将执行该快捷键的按键发送到聚焦终端，以便脚本作答。",
            @"Swipe up or down to resize panes.": @"向上或向下滑动以调整窗格大小。",
            @"That key can't be written as a shortcut.": @"该按键不能写入快捷键。",
            @"The Rex server is not responding to its status check. Open Diagnostics to inspect the server, then restart it to reconnect.": @"Rex 服务器未响应状态检查。请打开“诊断”查看服务器，然后重启服务器以重新连接。",
            @"The Rex server locator is malformed.": @"Rex 服务器地址格式错误。",
            @"The Rex terminal snapshot exceeded the 64 MiB limit.": @"Rex 终端快照超过 64 MiB 限制。",
            @"The Rex terminal snapshot is invalid.": @"Rex 终端快照无效。",
            @"The Rex terminal stream ended unexpectedly.": @"Rex 终端流意外结束。",
            @"The connection to the server was lost.": @"与服务器的连接已丢失。",
            @"The remote data connector requires a URL endpoint.": @"远程数据连接器需要 URL 端点。",
            @"The remote data endpoint is not a WebSocket URL.": @"远程数据端点不是 WebSocket URL。",
            @"The server is not ready for this operation.": @"服务器尚未准备好执行此操作。",
            @"Theme name or ID to fuzzy-match. Omit to open the theme picker.": @"用于模糊匹配的主题名称或 ID。省略后打开主题选择器。",
            @"These keys do nothing while the mode is active. Your configuration file blocks them.": @"模式激活时这些按键不起作用。配置文件阻止了它们。",
            @"Stop Recording": @"停止录制",
            @"Stop recording.": @"停止录制。",
            @"Accessing Environment's value outside of being installed on a View. This will always read the default value and will not update.": @"在 Environment 安装到 View 之外访问其值。这里始终会读取默认值，且不会更新。",
            @"Accessing Environment<%s>'s value outside of being installed on a View. This will always read the default value and will not update.": @"在 Environment<%s> 安装到 View 之外访问其值。这里始终会读取默认值，且不会更新。",
            @"An allocator is required to process OSC t but none was provided.": @"处理 OSC t 需要分配器，但未提供。",
            @"An authenticated Rex terminal control record exceeded the 64 KiB limit.": @"经过身份验证的 Rex 终端控制记录超过 64 KiB 限制。",
            @"An authenticated Rex terminal control record is malformed.": @"经过身份验证的 Rex 终端控制记录格式错误。",
            @"BUG IN SwiftNIO (possibly #572), please report! Connection reset (no error set).": @"SwiftNIO 内部错误（可能是 #572），请报告！连接已重置（未设置错误）。",
            @"Expected a UUID string for a RexSync server identifier.": @"RexSync 服务器标识符需要 UUID 字符串。",
            @"Expected an iTerm color property list.": @"需要 iTerm 颜色属性列表。",
            @"Leaving the client description out of a %ld-byte hello to keep it below %ld bytes.": @"省略客户端描述，以便将 %ld 字节的 hello 控制在 %ld 字节以内。",
            @"Rex began a second fragmented WebSocket message.": @"Rex 开始了第二条分片 WebSocket 消息。",
            @"Rex closed the WebSocket.": @"Rex 已关闭 WebSocket。",
            @"Rex closed the data connection with status 1002.": @"Rex 以状态 1002 关闭了数据连接。",
            @"Rex created the new tab without a pane.": @"Rex 创建了没有窗格的新标签页。",
            @"Rex did not select the requested WebSocket subprotocol.": @"Rex 未选择请求的 WebSocket 子协议。",
            @"Rex exceeded the negotiated WebSocket message size.": @"Rex 超过了协商的 WebSocket 消息大小。",
            @"Rex rejected the WebSocket upgrade.": @"Rex 拒绝了 WebSocket 升级。",
            @"Rex's terminals are composited by WindowServer, so their cost appears under both processes.": @"Rex 的终端由 WindowServer 合成，因此开销会同时显示在两个进程下。",
            @"Six-digit Display P3 hex color, for example #AABBCC, as read by Ghostty in P3.": @"六位 Display P3 十六进制颜色，例如 Ghostty 在 P3 中读取的 #AABBCC。",
            @"Socket was connected before flushing pending write.": @"套接字在刷新待写入数据前已连接。",
            @"Terminals use Display P3, so colors can be more saturated than sRGB.": @"终端使用 Display P3，因此颜色可能比 sRGB 更饱和。",
            @"The Rex WebSocket closed.": @"Rex WebSocket 已关闭。",
            @"The Rex WebSocket is closed.": @"Rex WebSocket 已关闭。",
            @"The Rex block that owned the data stream closed.": @"拥有数据流的 Rex 块已关闭。",
            @"The Rex API payload is invalid: ": @"Rex API 负载无效：",
            @"The Rex API request is invalid: ": @"Rex API 请求无效：",
            @"The Rex control connection was lost.": @"Rex 控制连接已丢失。",
            @"The Rex control connection closed.": @"Rex 控制连接已关闭。",
            @"The Rex control connection closed: ": @"Rex 控制连接已关闭：",
            @"The Rex control connection sent an invalid message: ": @"Rex 控制连接发送了无效消息：",
            @"The Rex control request ": @"Rex 控制请求 ",
            @"The Rex data connection closed.": @"Rex 数据连接已关闭。",
            @"The Rex terminal stream ended inside an authenticated control record.": @"Rex 终端流在经过身份验证的控制记录中结束。",
            @"The client_connection_changed connection_lost_at field is invalid.": @"client_connection_changed 的 connection_lost_at 字段无效。",
            @"The control welcome reconnect token is malformed.": @"控制欢迎消息中的重连令牌格式错误。",
            @"The identifier that the session's server assigned.": @"会话服务器分配的标识符。",
            @"The menu shows the current update's own title; this is the static fallback.": @"菜单显示当前更新自身的标题；这是静态备用文本。",
            @"The mode to enter, as the configuration names it.": @"要进入的模式，名称以配置文件中的定义为准。",
            @"The receive operation was cancelled.": @"接收操作已取消。",
            @"The response error for this request is not an object.": @"此请求的响应错误不是对象。",
            @"The selected file does not contain valid SVG markup.": @"所选文件不包含有效的 SVG 标记。",
            @"The session is not attached on the current connection.": @"会话未附加到当前连接。",
            @"The tab to show. Tabs count from 1, and -1 means the last tab.": @"要显示的标签页。标签页从 1 开始计数，-1 表示最后一个标签页。",
            @"Update Rex on the server to use ": @"更新服务器上的 Rex 以使用 ",
            @"the server uses revision ": @"服务器使用修订版 ",
            @"this app needs revisions ": @"此应用需要修订版 ",
            @"The Rex server supports API revisions ": @"Rex 服务器支持 API 修订版 ",
            @"The Rex server refused the connection: ": @"Rex 服务器拒绝连接：",
            @"Use theme": @"使用主题",
            @"Surface": @"表面",
            @"Content": @"内容",
            @"Dock only": @"仅程序坞",
            @"Menubar only": @"仅菜单栏",
            @"Enable status": @"启用状态",
            @"Play sound": @"播放声音",
            @"Play": @"播放",
            @"Play this sound": @"播放此声音",
            @"Attention": @"提醒",
            @"Completed": @"已完成",
            @"Play on completion": @"完成时播放",
            @"Play on error": @"出错时播放",
            @"Play when blocked": @"阻塞时播放",
            @"Success": @"成功",
            @"Warning": @"警告",
            @"Ready": @"就绪",
            @"Loading": @"加载中",
            @"Tap": @"点击",
            @"Attachment Status": @"附件状态",
            @"Cursor Style": @"光标样式",
            @"Cursor Text Color": @"光标文本颜色",
            @"Display P3 gamut": @"Display P3 色域",
            @"Foreground Color": @"前景颜色",
            @"Search commands, sessions, and tabs": @"搜索命令、会话和标签页",
            @"Select Terminal Font": @"选择终端字体",
            @"Selected Text Color": @"选中文本颜色",
            @"Settings search results": @"设置搜索结果",
            @"Terminal Font": @"终端字体",
            @"Terminal Font Size": @"终端字体大小",
            @"Terminal Padding Color": @"终端内边距颜色",
            @"Shortcut store": @"快捷键存储",
            @"Keymap client": @"按键映射客户端",
            @"Keymap install": @"按键映射安装",
            @"Client actions": @"客户端操作",
            @"Key routing": @"按键路由",
            @"Key resolve": @"按键解析",
            @"Key translate": @"按键转换",
            @"Key replay": @"按键重放",
            @"Fatal error": @"严重错误",
            @"Monospaced Fonts": @"等宽字体",
            @"Rex needs you to sign in to Tailscale": @"Rex 需要你登录 Tailscale",
            @"Rex server is running": @"Rex 服务器正在运行",
            @"The Rex server is running": @"Rex 服务器正在运行",
            @"Runtime directory:": @"运行时目录：",
            @"Just a moment...": @"请稍候…",
            @"Allows tailnet members": @"允许 Tailnet 成员",
            @"Needs machine approval": @"需要设备批准",
            @"Working directory": @"工作目录",
            @"None (development build)": @"无（开发构建）",
            @"Built for channel": @"构建频道",
            @"Last update check": @"上次检查更新",
            @"GPU Sample": @"GPU 采样",
            @"None using the GPU": @"没有程序使用 GPU",
            @"Tailnet Preference": @"Tailnet 偏好设置",
            @"Tailnet Hostname": @"Tailnet 主机名",
            @"Tailnet DNS Name": @"Tailnet DNS 名称",
            @"Last Resume Failure": @"上次恢复失败",
            @"Resolved Endpoint": @"已解析端点",
            @"Instance Generation": @"实例代次",
            @"Structure Status": @"结构状态",
            @"Presented Window": @"呈现窗口",
            @"Reporting Presentation": @"报告呈现",
            @"Reporting Generation": @"报告代次",
            @"Rex Server app icon": @"Rex 服务器应用图标",
            @"Screen & System Audio Recording": @"屏幕与系统音频录制",
            @"Rex returned an invalid process identifier": @"Rex 返回了无效的进程标识符",
            @"Rex couldn't open your browser. Use Reopen to try again.": @"Rex 无法打开浏览器。请使用“重新打开”重试。",
            @"Rex couldn’t open your browser. Use Reopen to try again.": @"Rex 无法打开浏览器。请使用“重新打开”重试。",
            @"Couldn’t migrate Ghostty theme": @"无法迁移 Ghostty 主题",
            @"Couldn't migrate Ghostty theme": @"无法迁移 Ghostty 主题",
            @"Couldn’t open link": @"无法打开链接",
            @"Couldn't open link": @"无法打开链接",
            @"Migrated your Ghostty themes": @"已迁移 Ghostty 主题",
            @"Migrated your Ghostty theme": @"已迁移 Ghostty 主题",
            @"Migrated your Ghostty settings": @"已迁移 Ghostty 设置",
            @"Migrated your Ghostty font": @"已迁移 Ghostty 字体",
            @"Lets command-line tools and agents open files in protected folders, like ~/Downloads and sandboxed apps' containers.": @"允许命令行工具和智能体打开受保护文件夹中的文件，例如 ~/Downloads 和沙盒应用容器中的文件。",
            @"This Mac leaves your tailnet. The next time you turn Tailscale on, you’ll need to sign in again.": @"此 Mac 将离开你的 Tailnet。下次开启 Tailscale 时，需要重新登录。",
            @"This Mac leaves your tailnet. The next time you turn Tailscale on, you'll need to sign in again.": @"此 Mac 将离开你的 Tailnet。下次开启 Tailscale 时，需要重新登录。",
            @"Recorded here. It takes priority over your configuration file and Rex’s defaults.": @"此处记录的快捷键优先于配置文件和 Rex 的默认设置。",
            @"Recorded here. It takes priority over your configuration file and Rex's defaults.": @"此处记录的快捷键优先于配置文件和 Rex 的默认设置。",
            @"Melt preview failed": @"预览合成失败",
            @"Type a terminal font size": @"输入终端字体大小",
            @"Tagged devices have no owner. Your tailnet’s policy decides who can connect.": @"带标签的设备没有所有者。你的 tailnet 策略决定谁可以连接。",
            @"Tagged devices have no owner. Your tailnet's policy decides who can connect.": @"带标签的设备没有所有者。你的 tailnet 策略决定谁可以连接。",
            @"Publishing failed and the package could not be restored:": @"发布失败，无法恢复软件包：",
            @"Migrated from Ghostty": @"已从 Ghostty 迁移",
            @"Missing bundled surface styles resource": @"缺少随附的表面样式资源",
            @"Unsupported surface style version": @"不受支持的表面样式版本",
            @"Unknown surface style key:": @"未知的表面样式键：",
            @"Unsupported or malformed Sequoia surface overrides.": @"Sequoia 表面样式覆盖不受支持或格式错误。",
            @"in app notifications": @"应用内通知",
            @"agent instructions": @"智能体说明",
            @"notification settings": @"通知设置",
            @"notification center": @"通知中心",
            @"notification position": @"通知位置",
            @"notification placement": @"通知位置",
            @"program activity": @"程序活动",
            @"activity indicators": @"活动指示器",
            @"notification dot": @"通知点",
            @"program finished": @"程序已完成",
            @"disable all working": @"停用所有运行中通知",
            @"enable working status": @"启用运行中状态",
            @"blocked notifications": @"阻塞通知",
            @"disable all blocked": @"停用所有阻塞通知",
            @"enable blocked status": @"启用阻塞状态",
            @"disable all errors": @"停用所有错误通知",
            @"enable error status": @"启用错误状态",
            @"disable all done": @"停用所有完成通知",
            @"enable done status": @"启用完成状态",
            @"customize notifications": @"自定义通知",
            @"always show idle processes in activity": @"始终在活动中显示空闲进程",
            @"each process in activity": @"活动中的每个进程",
            @"program notifications": @"程序通知",
            @"agent notifications": @"智能体通知",
            @"background notifications": @"后台通知",
            @"claude notification": @"Claude 通知",
            @"notify when done": @"完成时通知",
            @"notify when blocked": @"阻塞时通知",
            @"notifications without tab indicators": @"不显示标签页指示器的通知",
            @"badge application icon": @"在应用图标上显示标记",
            @"native notifications": @"原生通知",
            @"mac notifications": @"Mac 通知",
            @"tailscale alerts": @"Tailscale 警报",
            @"terminal notifications": @"终端通知",
            @"desktop notification": @"桌面通知",
            @"tailscale login notification": @"Tailscale 登录通知",
            @"device approval notification": @"设备批准通知",
            @"tailnet administrator": @"Tailnet 管理员",
            @"tailscale failure notification": @"Tailscale 故障通知",
            @"tailscale stopped": @"Tailscale 已停止",
            @"connection error": @"连接错误",
            @"preparing server": @"准备服务器",
            @"incompatible server": @"不兼容的服务器",
            @"available version": @"可用版本",
            @"use bundled server": @"使用随附的服务器",
            @"backward compatible": @"向后兼容",
            @"a newer server is available": @"有可用的新服务器",
            @"restarting is optional": @"可选重新启动",
            @"unavailable features": @"不可用功能",
            @"server settings have changed": @"服务器设置已更改",
            @"cannot connect to this server": @"无法连接到此服务器",
            @"this server requires a newer rex app": @"此服务器需要较新的 Rex app",
            @"server and app are incompatible": @"服务器与应用不兼容",
            @"server compatibility": @"服务器兼容性",
            @"Revision": @"修订版",
            @"Revision ": @"修订版 ",
            @"restart using included server": @"使用随附的服务器重新启动",
            @"restart from source": @"从源代码重新启动",
            @"copy remote address": @"复制远程地址",
            @"tailscale connection progress": @"Tailscale 连接进度",
            @"waiting for certificate": @"正在等待证书",
            @"connection progress": @"连接进度",
            @"assigned address": @"已分配地址",
            @"machine identity": @"设备身份",
            @"sign in to tailscale": @"登录 Tailscale",
            @"signed in to tailscale": @"已登录 Tailscale",
            @"enrolled account": @"已注册账户",
            @"signing in to tailscale": @"正在登录 Tailscale",
            @"preparing to sign in": @"正在准备登录",
            @"this may take a moment": @"这可能需要一些时间",
            @"ready to connect": @"已准备好连接",
            @"awaiting connection": @"正在等待连接",
            @"finish the process in your browser": @"在浏览器中完成此流程",
            @"taking longer than usual": @"所需时间比平时长",
            @"signing out of tailscale": @"正在退出 Tailscale",
            @"remove saved login": @"移除保存的登录信息",
            @"sign out progress": @"退出登录进度",
            @"Hide Activity": @"隐藏活动",
            @"Enable or disable all activity for working programs, or configure their tab indicators, notifications, Dock badges, and sounds individually.": @"启用或停用运行中程序的所有活动，或分别配置其标签页指示器、通知、程序坞标记和声音。",
            @"The Rex server refused the connection because it doesn't support the API revisions this app needs (": @"Rex 服务器拒绝连接，因为它不支持此应用需要的 API 修订版（",
            @"On": @"开启",
            @"Connected to Rex": @"已连接到 Rex",
            @"Update Rex.app, or restart the server to use the included one.": @"更新 Rex.app，或重新启动服务器以使用随附的服务器。",
            @"Hide Activity (⌘.)": @"隐藏活动 (⌘.)",
            @"Shown when a program finishes a task": @"程序完成任务时显示",
            @"Preserve width when resizing sidebar": @"调整侧边栏大小时保持宽度",
            @"Check for Updates": @"检查更新",
            @"Approve this Mac in Tailscale": @"在 Tailscale 中批准此 Mac",
            @"Location": @"位置",
            @"Restart is required before starting another server.": @"启动另一个服务器前需要重启。",
            @"No Rex installation is available.": @"没有可用的 Rex 安装。",
            @"New Session ": @"新建会话 ",
            @"Let agents label the session after the task they're working on.": @"允许智能体根据正在处理的任务为会话命名。",
            @"Drag this icon into the list in System Settings to grant ": @"将此图标拖入系统设置中的列表以授予 ",
            @"Font": @"字体",
            @"Cancel": @"取消",
            @"Rex does not provide transport authentication. Use a trusted tunnel such as Tailscale.": @"Rex 不提供传输身份验证。请使用 Tailscale 等受信任的隧道。",
            @"Connecting to Rex": @"正在连接 Rex",
            @"Adjust pane spacing, headers, active and inactive appearance, and split balancing.": @"调整窗格间距、标题、活动和非活动外观以及分栏平衡。",
            @". Update Rex on the server or this app.": @"。请更新服务器上的 Rex 或此应用。",
            @"Choose fonts, in order, for characters the terminal font doesn't have.": @"按顺序选择用于显示终端字体不包含字符的字体。",
            @"Couldn’t find the Ghostty theme ": @"找不到 Ghostty 主题 ",
            @"This app can't send this ": @"此应用无法发送此 ",
            @"Show on Rex's Dock icon how many tabs have a program that's blocked, failed, or finished that you haven't seen.": @"在 Rex 的程序坞图标上显示你尚未查看的阻塞、失败或已完成程序的标签页数量。",
            @"Adjust the stroke weight of a variable terminal font.": @"调整可变终端字体的字重。",
            @"Edit": @"编辑",
            @"Open Onboarding Session": @"打开入门会话",
            @"Go to Directory": @"前往目录",
            @"The theme is missing valid colors for:": @"主题缺少有效颜色：",
            @"Check serving progress and certificate readiness, retry, copy the address, or pair a device using its QR code.": @"查看服务进度和证书状态、重试、复制地址，或使用二维码配对设备。",
            @"The Rex server refused the connection because it doesn’t support the API revisions this app needs (": @"Rex 服务器拒绝连接，因为它不支持此应用需要的 API 修订版（",
            @"Smooth the edges of terminal text.": @"平滑终端文字边缘。",
            @"Enable or disable all activity for finished programs, or configure their tab indicators, notifications, Dock badges, and sounds individually.": @"启用或停用已完成程序的所有活动，或分别配置其标签页指示器、通知、程序坞标记和声音。",
            @"Connect to your local Rex server over your Tailnet.": @"通过 Tailnet 连接到本地 Rex 服务器。",
            @". Update Rex on the server.": @"。请更新服务器上的 Rex。",
            @"Ended": @"已结束",
            @" request to a server that uses API revision ": @" 请求，服务器使用 API 修订版 ",
            @"Web Client Origins": @"Web 客户端来源",
            @"Browser origins allowed to open Rex WebSocket streams. The hosted Rex client is always allowed. Wildcards match subdomains, e.g. https://*.vercel.app. Changes apply after Rex restarts.": @"允许打开 Rex WebSocket 流的浏览器来源。托管的 Rex 客户端始终允许。通配符匹配子域名，例如 https://*.vercel.app。更改将在 Rex 重启后生效。",
            @"Host": @"主机",
            @"Choose Comfortable or Compact pane surfaces and spacing.": @"选择舒适或紧凑的窗格表面和间距。",
            @"Choose a custom, default, or built-in palette used in light mode.": @"选择浅色模式使用的自定义、默认或内置调色板。",
            @"Enter a size from ": @"输入大小，范围为 ",
            @"Migrate my keybindings and settings from ": @"从以下来源迁移我的快捷键和设置：",
            @"Resuming (attempt ": @"正在恢复（尝试 ",
            @"File": @"文件",
            @"Fade inactive panes": @"淡化非活动窗格",
            @"Manage browser origins allowed to open Rex WebSocket streams.": @"管理允许打开 Rex WebSocket 流的浏览器来源。",
            @"New Session on Host": @"在主机上新建会话",
            @"Update": @"更新",
            @"App Version": @"应用版本",
            @"Choose Off, Slow, Normal, Fast, or Custom to edit the blink interval.": @"选择关闭、慢速、正常、快速或自定义来编辑闪烁间隔。",
            @"Independently configure tab indicators, system notifications, Dock badges, and sounds for program activity.": @"分别配置程序活动的标签页指示器、系统通知、程序坞标记和声音。",
            @"No Remote Hosts": @"没有远程主机",
            @"Drag around the center to change hue and outward to increase chroma.": @"绕中心拖动可更改色相，向外拖动可提高色度。",
            @"Shown when a program is busy or reports progress": @"程序忙碌或报告进度时显示",
            @"API Version": @"API 版本",
            @"Show update-channel, installation, local API, and web-client origin settings.": @"显示更新频道、安装、本地 API 和 Web 客户端来源设置。",
            @"Filter Shortcuts...": @"筛选快捷键…",
            @"Choose Default artwork, Use theme for background and foreground colors, or Use theme accent for accents.": @"选择默认图案、使用主题的背景和前景色，或使用主题强调色。",
            @"Enable or disable all activity for programs waiting for you, or configure their tab indicators, notifications, Dock badges, and sounds individually.": @"启用或停用等待你操作的程序的所有活动，或分别配置其标签页指示器、通知、程序坞标记和声音。",
            @"Adjust terminal text size in points.": @"以磅为单位调整终端文字大小。",
            @"Click to choose a color.": @"点击选择颜色。",
            @"Add a Rex HTTP or HTTPS address to use its sessions in every window.": @"添加 Rex HTTP 或 HTTPS 地址，以便在每个窗口中使用其会话。",
            @"Help": @"帮助",
            @"Set the time between cursor blinks in milliseconds when Blink speed is Custom.": @"将闪烁速度设为自定义时，设置光标闪烁间隔（毫秒）。",
            @"Show the running program and its directory instead of titles that shells set.": @"显示正在运行的程序及其目录，而不是 Shell 设置的标题。",
            @"Changes apply to new agent sessions.": @"更改将应用于新的智能体会话。",
            @"Downloading update": @"正在下载更新",
            @"Reconnecting to Rex": @"正在重新连接 Rex",
            @"Browse monospaced or all installed fonts to choose the terminal typeface.": @"浏览等宽字体或所有已安装字体，以选择终端字体。",
            @"Restarted the Rex server": @"已重新启动 Rex 服务器",
            @"No Ghostty configuration was found. Searched: ": @"未找到 Ghostty 配置。已搜索：",
            @"Choose a custom, default, or built-in palette used in dark mode.": @"选择深色模式使用的自定义、默认或内置调色板。",
            @"Use the pane background or extend edge-cell backgrounds into the padding.": @"使用窗格背景，或将边缘单元格背景延伸到内边距。",
            @"Manage the local server, compatibility, and diagnostics.": @"管理本地服务器、兼容性和诊断。",
            @"Enable or disable all activity for programs reporting errors, or configure their tab indicators, notifications, Dock badges, and sounds individually.": @"启用或停用报告错误的程序的所有活动，或分别配置其标签页指示器、通知、程序坞标记和声音。",
            @"Play a sound when a program in a tab is blocked, reports an error, or finishes.": @"标签页中的程序被阻塞、报告错误或完成时播放声音。",
            @"Round the corners of terminal text selections.": @"将终端文本选择区域的边角设为圆角。",
            @"Policy": @"策略",
            @"Rex Installation": @"Rex 安装",
            @"Show the title and controls above each pane.": @"在每个窗格上方显示标题和控件。",
            @"Add and manage remote Rex hosts, view connection status, and retry connection failures.": @"添加和管理远程 Rex 主机，查看连接状态，并重试连接失败的主机。",
            @"This app can’t send this ": @"此应用无法发送此 ",
            @"Shown when a program needs you to respond": @"程序需要你响应时显示",
            @"Server Version": @"服务器版本",
            @"Closed": @"已关闭",
            @"Available with horizontal tabs: expand tabs equally to fill the bar, showing backgrounds only for two or more tabs.": @"使用横向标签页时可用：让标签页等宽填满栏，仅在有两个或更多标签页时显示背景。",
            @"Couldn't find the Ghostty theme ": @"找不到 Ghostty 主题 ",
            @"Installs the Rex skill and hooks for Claude Code, Codex, and other agents.": @"为 Claude Code、Codex 和其他智能体安装 Rex 技能和钩子。",
            @"Dismiss notice (": @"关闭通知 (",
            @"Copy local Rex endpoint": @"复制本地 Rex 端点",
            @"Shown when a program reports that something went wrong": @"程序报告发生问题时显示",
            @"Restrict callers to your account or allow tailnet members.": @"仅允许你的账户访问，或允许 Tailnet 成员访问。",
            @"Available with sidebar tab styles: choose whether the sidebar resizes the window.": @"使用侧边栏标签页样式时可用：选择侧边栏是否调整窗口大小。",
            @"Check serving progress, copy the address, or pair another device.": @"查看服务进度、复制地址，或配对其他设备。",
            @"Nothing named ": @"没有名为 ",
            @"Connect Rex to your tailnet and control who can access it.": @"将 Rex 连接到你的 Tailnet，并控制谁可以访问它。",
            @"Agents can control Rex: open sessions, arrange panes, run commands, and change your settings.": @"智能体可以控制 Rex：打开会话、排列窗格、运行命令和更改设置。",
            @"revisions this app needs (": @"修订版，此应用需要（",
            @"Copy the configuration file": @"复制配置文件",
            @"Pair Device with QR Code": @"使用二维码配对设备",
            @"Reconnecting (attempt ": @"正在重新连接（尝试 ",
            @"Choose an installed face of the terminal font, such as Light or Book.": @"选择终端字体的已安装字形，例如 Light 或 Book。",
            @"Available with vertical tabs: resize panes when showing or hiding the sidebar, keeping the window width unchanged.": @"使用纵向标签页时可用：显示或隐藏侧边栏时调整窗格大小，同时保持窗口宽度不变。",
            @"Update Channel": @"更新频道",
            @"Host Details": @"主机详情",
            @"Show colored icons Always, For active panes, For active tabs, or Never.": @"选择始终、活动窗格、活动标签页或从不显示彩色图标。",
            @"Add a Ghostty or iTerm palette to your custom themes.": @"将 Ghostty 或 iTerm 调色板添加到自定义主题。",
            @"Failed": @"失败",
            @"None": @"无",
        };
        translatedValues = [NSSet setWithArray:map.allValues];
    });
    NSString *exact = map[s];
    if (exact) return exact;
    // Getter hooks and polling see the same translated labels repeatedly.
    // Known complete translations need no dynamic-pattern parsing.
    if ([translatedValues containsObject:s]) return s;
    if ([s hasPrefix:@"快捷键 › "]) {
        for (NSString *prefix in @[@"See the keys bound to ", @"Record, remove, or reset the keys bound to ", @"录制、移除或重置绑定到 ", @"查看绑定到 "]) {
            NSRange range = [s rangeOfString:prefix];
            if (range.location != NSNotFound) return [[s substringToIndex:range.location] stringByAppendingString:RXTranslate([s substringFromIndex:range.location])];
        }
    }
    for (NSString *suffix in @[@" result", @" results"]) {
        if ([s hasSuffix:suffix]) {
            NSString *count = [s substringToIndex:s.length - suffix.length];
            NSCharacterSet *notDigit = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            if (count.length && [count rangeOfCharacterFromSet:notDigit].location == NSNotFound) return [count stringByAppendingString:@" 项结果"];
        }
    }
    NSString *shortcutPrefix = @"See the keys bound to ";
    NSString *shortcutSuffix = @" and where each came from.";
    if ([s hasPrefix:shortcutPrefix] && [s hasSuffix:shortcutSuffix] && s.length >= shortcutPrefix.length + shortcutSuffix.length) {
        NSString *action = [s substringWithRange:NSMakeRange(shortcutPrefix.length, s.length - shortcutPrefix.length - shortcutSuffix.length)];
        return [NSString stringWithFormat:@"查看绑定到 %@ 的按键及其来源。", RXTranslate(action)];
    }
    for (NSString *suffix in @[@" 的按键", @" 的按键。"]) {
        NSString *prefix = @"录制、移除或重置绑定到 ";
        if ([s hasPrefix:prefix] && [s hasSuffix:suffix] && s.length >= prefix.length + suffix.length) {
            NSString *action = [s substringWithRange:NSMakeRange(prefix.length, s.length - prefix.length - suffix.length)];
            if ([action hasSuffix:@"."]) return [NSString stringWithFormat:@"%@%@ 的按键。", prefix, RXTranslate([action substringToIndex:action.length - 1])];
            return [NSString stringWithFormat:@"%@%@%@", prefix, RXTranslate(action), suffix];
        }
    }
    NSString *translatedPrefix = @"查看绑定到 ";
    NSString *translatedSuffix = @" 的按键及其来源。";
    if ([s hasPrefix:translatedPrefix] && [s hasSuffix:translatedSuffix] && s.length >= translatedPrefix.length + translatedSuffix.length) {
        NSString *action = [s substringWithRange:NSMakeRange(translatedPrefix.length, s.length - translatedPrefix.length - translatedSuffix.length)];
        return [NSString stringWithFormat:@"%@%@%@", translatedPrefix, RXTranslate(action), translatedSuffix];
    }
    NSString *actionPrefix = @"录制、移除或重置以下操作的按键：";
    if ([s hasPrefix:actionPrefix]) {
        NSString *tail = [s substringFromIndex:actionPrefix.length];
        NSString *action = [tail hasSuffix:@"."] ? [tail substringToIndex:tail.length - 1] : tail;
        NSString *translated = map[action];
        if (translated) return [NSString stringWithFormat:@"%@%@%@", actionPrefix, translated, [tail hasSuffix:@"."] ? @"。" : @""];
    }
    // Translate shortcut wrappers before general substitutions can return a
    // partially translated sentence (for example a Diagnostics action name).
    if ([s hasPrefix:@"Press a shortcut for "]) {
        return [NSString stringWithFormat:@"按下用于%@的快捷键", RXTranslate([s substringFromIndex:[@"Press a shortcut for " length]])];
    }
    if ([s hasPrefix:@"Change the shortcut for "]) {
        return [NSString stringWithFormat:@"修改 %@ 的快捷键", RXTranslate([s substringFromIndex:[@"Change the shortcut for " length]])];
    }
    if ([s hasPrefix:@"Record a shortcut for "]) {
        return [NSString stringWithFormat:@"录制 %@ 的快捷键", RXTranslate([s substringFromIndex:[@"Record a shortcut for " length]])];
    }
    if ([s hasPrefix:@"Add a shortcut for "]) {
        return [NSString stringWithFormat:@"为 %@ 添加快捷键", RXTranslate([s substringFromIndex:[@"Add a shortcut for " length]])];
    }
    if ([s hasPrefix:@"Record, remove, or reset the keys bound to "]) {
        NSString *action = [s substringFromIndex:[@"Record, remove, or reset the keys bound to " length]];
        if ([action hasSuffix:@"."]) return [NSString stringWithFormat:@"录制、移除或重置绑定到 %@ 的按键。", RXTranslate([action substringToIndex:action.length - 1])];
        return [NSString stringWithFormat:@"录制、移除或重置绑定到 %@ 的按键", RXTranslate(action)];
    }
    // App menus use the installed bundle's display name. Match known Rex names
    // exactly so similarly prefixed session titles and user text stay untouched.
    for (NSString *appName in @[@"Rex", @"Rex Beta", @"Rex 中文版", @"Rex Beta 中文版"]) {
        if ([s isEqualToString:[@"Quit " stringByAppendingString:appName]]) return [@"退出 " stringByAppendingString:appName];
        if ([s isEqualToString:[@"Hide " stringByAppendingString:appName]]) return [@"隐藏 " stringByAppendingString:appName];
        if ([s isEqualToString:[@"About " stringByAppendingString:appName]]) return [@"关于 " stringByAppendingString:appName];
        NSString *about = [@"About " stringByAppendingString:appName];
        if ([s isEqualToString:[about stringByAppendingString:@"…"]] || [s isEqualToString:[about stringByAppendingString:@"..."]]) {
            return [[@"关于 " stringByAppendingString:appName] stringByAppendingString:@"…"];
        }
    }
    if ([s containsString:@"Hue "] || [s containsString:@"chroma "] || [s containsString:@"Lightness "]) {
        NSString *translatedDetails = [s stringByReplacingOccurrencesOfString:@"Hue " withString:@"色相 "];
        translatedDetails = [translatedDetails stringByReplacingOccurrencesOfString:@" degrees" withString:@"°"];
        translatedDetails = [translatedDetails stringByReplacingOccurrencesOfString:@"chroma " withString:@"色度 "];
        translatedDetails = [translatedDetails stringByReplacingOccurrencesOfString:@"Lightness " withString:@"亮度 "];
        return translatedDetails;
    }
    // Workspace notifications append the copied payload to the English
    // sentence. Keep the payload (version, commit, or path) untouched while
    // translating the sentence prefix used by both visible and AX surfaces.
    if ([s hasPrefix:@"Copied version info. "]) {
        return [NSString stringWithFormat:@"已复制版本信息 %@", [s substringFromIndex:[@"Copied version info. " length]]];
    }
    if ([s hasPrefix:@"Copied debug info. "]) {
        return [NSString stringWithFormat:@"已复制调试信息 %@", [s substringFromIndex:[@"Copied debug info. " length]]];
    }
    if ([s hasPrefix:@"Copied config file path. "]) {
        return [NSString stringWithFormat:@"已复制配置文件路径 %@", [s substringFromIndex:[@"Copied config file path. " length]]];
    }
    if ([s hasPrefix:@"Dismiss notice ("]) {
        return [NSString stringWithFormat:@"关闭通知 (%@", [s substringFromIndex:[@"Dismiss notice (" length]]];
    }
    if ([s hasSuffix:@"\" is still running."]) {
        return [[s substringToIndex:s.length - [@"\" is still running." length]] stringByAppendingString:@"”仍在运行。"];
    }
    if ([s hasSuffix:@"\" isn't available here right now."]) {
        return [[s substringToIndex:s.length - [@"\" isn't available here right now." length]] stringByAppendingString:@"”当前无法使用。"];
    }
    if ([s hasSuffix:@"\" is not a valid JSON pointer to a member."]) {
        return [[s substringToIndex:s.length - [@"\" is not a valid JSON pointer to a member." length]] stringByAppendingString:@"”不是有效的 JSON 指针成员。"];
    }
    if ([s hasSuffix:@"\" is not a valid JSON pointer to a member. It must start with \\\"/\\\", write \\\"~\\\" as \\\"~0\\\", and not end in \\\"-\\\"."]) {
        return [[s substringToIndex:s.length - [@"\" is not a valid JSON pointer to a member. It must start with \\\"/\\\", write \\\"~\\\" as \\\"~0\\\", and not end in \\\"-\\\"." length]] stringByAppendingString:@"”不是有效的 JSON 指针成员。必须以“/”开头，将“~”写作“~0”，且不能以“-”结尾。"];
    }
    if ([s hasPrefix:@"Enter a size from "]) {
        return [NSString stringWithFormat:@"输入大小，范围为 %@", [s substringFromIndex:[@"Enter a size from " length]]];
    }
    if ([s hasPrefix:@"Nothing named "]) {
        return [NSString stringWithFormat:@"没有名为 %@", [s substringFromIndex:[@"Nothing named " length]]];
    }
    if ([s hasPrefix:@"No Ghostty configuration was found. Searched: "]) {
        return [NSString stringWithFormat:@"未找到 Ghostty 配置。已搜索：%@", [s substringFromIndex:[@"No Ghostty configuration was found. Searched: " length]]];
    }
    if ([s hasPrefix:@"Couldn’t find the Ghostty theme "]) {
        return [NSString stringWithFormat:@"找不到 Ghostty 主题 %@", [s substringFromIndex:[@"Couldn’t find the Ghostty theme " length]]];
    }
    if ([s hasPrefix:@"Couldn't find the Ghostty theme "]) {
        return [NSString stringWithFormat:@"找不到 Ghostty 主题 %@", [s substringFromIndex:[@"Couldn't find the Ghostty theme " length]]];
    }
    if ([s hasPrefix:@"Migrate my keybindings and settings from "]) {
        return [NSString stringWithFormat:@"从 %@ 迁移我的快捷键和设置", [s substringFromIndex:[@"Migrate my keybindings and settings from " length]]];
    }
    if ([s hasPrefix:@"Resuming (attempt "]) {
        NSString *tail = [s substringFromIndex:[@"Resuming (attempt " length]];
        tail = [tail stringByReplacingOccurrencesOfString:@")" withString:@"）"];
        return [NSString stringWithFormat:@"正在恢复（尝试 %@", tail];
    }
    if ([s hasPrefix:@"Reconnecting (attempt "]) {
        NSString *tail = [s substringFromIndex:[@"Reconnecting (attempt " length]];
        tail = [tail stringByReplacingOccurrencesOfString:@")" withString:@"）"];
        return [NSString stringWithFormat:@"正在重新连接（尝试 %@", tail];
    }
    if ([s hasPrefix:@"Drag this icon into the list in System Settings to grant "]) {
        return [NSString stringWithFormat:@"将此图标拖入系统设置中的列表以授予 %@", [s substringFromIndex:[@"Drag this icon into the list in System Settings to grant " length]]];
    }
    if ([s hasPrefix:@"Recorded here. It takes priority over your configuration file and Rex"]) {
        return @"此处记录的快捷键优先于配置文件和 Rex 的默认设置。";
    }
    if ([s hasPrefix:@"This Mac leaves your tailnet. The next time you turn Tailscale on, you"]) {
        return @"此 Mac 将离开你的 Tailnet。下次开启 Tailscale 时，需要重新登录。";
    }
    if ([s hasPrefix:@"Press a shortcut"]) {
        return [NSString stringWithFormat:@"按下快捷键%@", [s substringFromIndex:[@"Press a shortcut" length]]];
    }
    if ([s hasPrefix:@"Working directory "]) {
        return [NSString stringWithFormat:@"工作目录 %@", [s substringFromIndex:[@"Working directory " length]]];
    }
    if ([s hasPrefix:@"Built for channel "]) {
        return [NSString stringWithFormat:@"构建频道 %@", [s substringFromIndex:[@"Built for channel " length]]];
    }
    if ([s hasPrefix:@"Runtime directory: "]) {
        return [NSString stringWithFormat:@"运行时目录：%@", [s substringFromIndex:[@"Runtime directory: " length]]];
    }
    if ([s hasPrefix:@"Unable to load surface styles at "]) {
        return [NSString stringWithFormat:@"无法加载表面样式：%@", [s substringFromIndex:[@"Unable to load surface styles at " length]]];
    }
    if ([s hasPrefix:@"Ghostty configuration includes are nested more than eight levels deep at "]) {
        return [NSString stringWithFormat:@"Ghostty 配置包含嵌套超过八层：%@", [s substringFromIndex:[@"Ghostty configuration includes are nested more than eight levels deep at " length]]];
    }
    if ([s hasPrefix:@"Remove the shortcuts recorded here for "]) {
        return [NSString stringWithFormat:@"移除此处记录的快捷键：%@", [s substringFromIndex:[@"Remove the shortcuts recorded here for " length]]];
    }
    if ([s hasPrefix:@"Publishing failed and the package could not be restored: "]) {
        return [NSString stringWithFormat:@"发布失败，无法恢复软件包：%@", [s substringFromIndex:[@"Publishing failed and the package could not be restored: " length]]];
    }
    if ([s hasPrefix:@"Migrated from Ghostty"]) {
        return [NSString stringWithFormat:@"已从 Ghostty 迁移%@", [s substringFromIndex:[@"Migrated from Ghostty" length]]];
    }
    if ([s hasPrefix:@"Waiting for the next key after "]) {
        return [NSString stringWithFormat:@"正在等待下一个按键，当前按键：%@", [s substringFromIndex:[@"Waiting for the next key after " length]]];
    }
    if ([s hasPrefix:@"The running Rex server is incompatible with this version of Rex.app."]) {
        return [NSString stringWithFormat:@"正在运行的 Rex 服务器与此版本的 Rex.app 不兼容。%@", [s substringFromIndex:[@"The running Rex server is incompatible with this version of Rex.app." length]]];
    }
    if ([s hasPrefix:@"The theme is missing valid colors for: "]) {
        NSString *suffix = [s substringFromIndex:[@"The theme is missing valid colors for: " length]];
        NSArray *parts = [suffix componentsSeparatedByString:@","];
        NSMutableArray *translatedParts = [NSMutableArray arrayWithCapacity:parts.count];
        for (NSString *rawPart in parts) {
            NSString *part = [rawPart stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([part isEqualToString:@"background"]) part = @"背景色";
            else if ([part isEqualToString:@"foreground"]) part = @"前景色";
            else if ([part hasPrefix:@"palette "]) part = [@"调色板 " stringByAppendingString:[part substringFromIndex:[@"palette " length]]];
            [translatedParts addObject:part];
        }
        return [NSString stringWithFormat:@"主题缺少有效颜色：%@", [translatedParts componentsJoinedByString:@"、"]];
    }
    if ([s hasPrefix:@"You don’t have permission to view "]) {
        return [NSString stringWithFormat:@"你没有权限查看 %@", [s substringFromIndex:[@"You don’t have permission to view " length]]];
    }
    if ([s hasPrefix:@"You don't have permission to view "]) {
        return [NSString stringWithFormat:@"你没有权限查看 %@", [s substringFromIndex:[@"You don't have permission to view " length]]];
    }
    if ([s hasPrefix:@"No folders named "]) {
        return [NSString stringWithFormat:@"没有名为 %@ 的文件夹", [s substringFromIndex:[@"No folders named " length]]];
    }
    if ([s hasPrefix:@"Couldn’t load this folder ("]) {
        return [NSString stringWithFormat:@"无法加载此文件夹（%@", [s substringFromIndex:[@"Couldn’t load this folder (" length]]];
    }
    if ([s hasPrefix:@"Couldn't load this folder ("]) {
        return [NSString stringWithFormat:@"无法加载此文件夹（%@", [s substringFromIndex:[@"Couldn't load this folder (" length]]];
    }
    if ([s hasPrefix:@"No app is set to open "]) {
        return [NSString stringWithFormat:@"没有设置用于打开的应用：%@", [s substringFromIndex:[@"No app is set to open " length]]];
    }
    if ([s hasSuffix:@" is not a folder"]) {
        return [NSString stringWithFormat:@"%@ 不是文件夹", [s substringToIndex:s.length - [@" is not a folder" length]]];
    }
    if ([s hasSuffix:@" is not an HTTP or HTTPS address"]) {
        return [NSString stringWithFormat:@"%@ 不是 HTTP 或 HTTPS 地址", [s substringToIndex:s.length - [@" is not an HTTP or HTTPS address" length]]];
    }
    if ([s hasPrefix:@"Couldn’t Connect to "]) {
        return [NSString stringWithFormat:@"无法连接到 %@", [s substringFromIndex:[@"Couldn’t Connect to " length]]];
    }
    if ([s hasPrefix:@"Couldn't Connect to "]) {
        return [NSString stringWithFormat:@"无法连接到 %@", [s substringFromIndex:[@"Couldn't Connect to " length]]];
    }
    if ([s hasPrefix:@"Another client resized this terminal to "]) {
        return [NSString stringWithFormat:@"另一个客户端已将此终端调整为 %@", [s substringFromIndex:[@"Another client resized this terminal to " length]]];
    }
    if ([s hasPrefix:@"Rex.app includes version "]) {
        return [NSString stringWithFormat:@"Rex.app 包含版本 %@", [s substringFromIndex:[@"Rex.app includes version " length]]];
    }
    if ([s hasPrefix:@"Running server version: "]) {
        return [NSString stringWithFormat:@"运行中服务器版本：%@", [s substringFromIndex:[@"Running server version: " length]]];
    }
    if ([s hasPrefix:@"Connection attempt "] && [s hasSuffix:@" failed. Choose to try again now."]) {
        NSString *attempt = [s substringWithRange:NSMakeRange([@"Connection attempt " length], s.length - [@"Connection attempt " length] - [@" failed. Choose to try again now." length])];
        return [NSString stringWithFormat:@"连接尝试 %@ 失败。请选择立即重试。", attempt];
    }
    if ([s hasPrefix:@"Recently used path. Press "] && [s hasSuffix:@" to remove from recents."]) {
        NSString *path = [s substringWithRange:NSMakeRange([@"Recently used path. Press " length], s.length - [@"Recently used path. Press " length] - [@" to remove from recents." length])];
        return [NSString stringWithFormat:@"最近使用的路径。按下 %@ 从最近记录中移除。", path];
    }
    if ([s hasPrefix:@"The server supports API revisions "]) {
        return [NSString stringWithFormat:@"服务器支持 API 修订版 %@", [s substringFromIndex:[@"The server supports API revisions " length]]];
    }
    if ([s hasSuffix:@" was not found on this server"]) {
        return [NSString stringWithFormat:@"%@未在此服务器上找到", [s substringToIndex:s.length - [@" was not found on this server" length]]];
    }
    if ([s hasPrefix:@"no host has a session "]) {
        return [NSString stringWithFormat:@"没有主机拥有会话 %@", [s substringFromIndex:[@"no host has a session " length]]];
    }
    if ([s hasPrefix:@"rex exited with status "]) {
        return [NSString stringWithFormat:@"rex 已退出，状态码 %@", [s substringFromIndex:[@"rex exited with status " length]]];
    }
    if ([s hasPrefix:@"Reset Overrides ("]) {
        return [NSString stringWithFormat:@"重置覆盖（%@", [s substringFromIndex:[@"Reset Overrides (" length]]];
    }
    if ([s hasPrefix:@"The remote host couldn’t be added"] || [s hasPrefix:@"The remote host couldn't be added"]) return @"无法添加远程主机。";
    if ([s hasPrefix:@"The remote host couldn’t be updated"] || [s hasPrefix:@"The remote host couldn't be updated"]) return @"无法更新远程主机。";
    if ([s hasPrefix:@"The saved hosts couldn’t be read"] || [s hasPrefix:@"The saved hosts couldn't be read"]) return @"无法读取已保存的主机，因此不会保存此列表的更改。";
    if ([s hasPrefix:@"Rex must be updated: "]) {
        return [NSString stringWithFormat:@"Rex 必须更新：%@", [s substringFromIndex:[@"Rex must be updated: " length]]];
    }
    if ([s hasPrefix:@"The Rex server command failed: "]) {
        return [NSString stringWithFormat:@"Rex 服务器命令失败：%@", [s substringFromIndex:[@"The Rex server command failed: " length]]];
    }
    if ([s hasPrefix:@"The Rex server did not become ready: "]) {
        return [NSString stringWithFormat:@"Rex 服务器未能就绪：%@", [s substringFromIndex:[@"The Rex server did not become ready: " length]]];
    }
    if ([s hasPrefix:@"The Rex server could not be launched: "]) {
        return [NSString stringWithFormat:@"Rex 服务器无法启动：%@", [s substringFromIndex:[@"The Rex server could not be launched: " length]]];
    }
    if ([s hasPrefix:@"The Rex server working directory could not be prepared: "]) {
        return [NSString stringWithFormat:@"Rex 服务器工作目录无法准备：%@", [s substringFromIndex:[@"The Rex server working directory could not be prepared: " length]]];
    }
    if ([s hasPrefix:@"The durable host ID is "]) {
        return [NSString stringWithFormat:@"持久主机 ID 为 %@", [s substringFromIndex:[@"The durable host ID is " length]]];
    }
    if ([s hasPrefix:@"Set Cursor Blink Interval to "]) {
        return [NSString stringWithFormat:@"将光标闪烁间隔设为 %@", [s substringFromIndex:[@"Set Cursor Blink Interval to " length]]];
    }
    if ([s hasPrefix:@"Choose a preset or enter a whole number from "]) {
        return [NSString stringWithFormat:@"选择预设，或输入一个整数，范围为 %@", [s substringFromIndex:[@"Choose a preset or enter a whole number from " length]]];
    }
    if ([s hasPrefix:@"Server supports "]) return [NSString stringWithFormat:@"服务器支持 %@", [s substringFromIndex:[@"Server supports " length]]];
    if ([s hasPrefix:@"Rex.app supports "]) return [NSString stringWithFormat:@"Rex.app 支持 %@", [s substringFromIndex:[@"Rex.app supports " length]]];
    if ([s hasPrefix:@"Rex.app uses Revision "]) return [NSString stringWithFormat:@"Rex.app 使用修订版 %@", [s substringFromIndex:[@"Rex.app uses Revision " length]]];
    if ([s hasPrefix:@"Couldn’t read Rex Server’s permissions: "]) return [NSString stringWithFormat:@"无法读取 Rex 服务器的权限：%@", [s substringFromIndex:[@"Couldn’t read Rex Server’s permissions: " length]]];
    if ([s hasPrefix:@"Couldn't read Rex Server's permissions: "]) return [NSString stringWithFormat:@"无法读取 Rex 服务器的权限：%@", [s substringFromIndex:[@"Couldn't read Rex Server's permissions: " length]]];
    if ([s hasPrefix:@"Unable to follow Rex server logs: "]) return [NSString stringWithFormat:@"无法跟踪 Rex 服务器日志：%@", [s substringFromIndex:[@"Unable to follow Rex server logs: " length]]];
    if ([s hasPrefix:@"Unable to observe Rex server status: "]) return [NSString stringWithFormat:@"无法观察 Rex 服务器状态：%@", [s substringFromIndex:[@"Unable to observe Rex server status: " length]]];
    if ([s hasPrefix:@"status exited with "]) return [NSString stringWithFormat:@"状态退出，结果为 %@", [s substringFromIndex:[@"status exited with " length]]];
    if ([s hasPrefix:@"Rex server status is ambiguous ("]) return [NSString stringWithFormat:@"Rex 服务器状态不明确（%@", [s substringFromIndex:[@"Rex server status is ambiguous (" length]]];
    if ([s hasPrefix:@"Rex server status could not be verified. "]) return [NSString stringWithFormat:@"无法验证 Rex 服务器状态。%@", [s substringFromIndex:[@"Rex server status could not be verified. " length]]];
    if ([s hasPrefix:@"Rex Server is running as part of "]) return [NSString stringWithFormat:@"Rex 服务器属于 %@", [s substringFromIndex:[@"Rex Server is running as part of " length]]];
    if ([s hasPrefix:@"Rex server is running as part of "]) return [NSString stringWithFormat:@"Rex 服务器属于 %@", [s substringFromIndex:[@"Rex server is running as part of " length]]];
    if ([s hasPrefix:@"The running Rex server and this Rex.app share no version of the control API."]) return [NSString stringWithFormat:@"正在运行的 Rex 服务器与此 Rex.app 没有共同的控制 API 版本。%@", [s substringFromIndex:[@"The running Rex server and this Rex.app share no version of the control API." length]]];
    if ([s hasPrefix:@"The running Rex server is older than this Rex.app. "]) return [NSString stringWithFormat:@"正在运行的 Rex 服务器版本低于此 Rex.app。%@", [s substringFromIndex:[@"The running Rex server is older than this Rex.app. " length]]];
    NSString *controlAPIError = s;
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex API payload is invalid: " withString:@"Rex API 负载无效："];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex API request is invalid: " withString:@"Rex API 请求无效："];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex control connection was lost." withString:@"Rex 控制连接已丢失。"];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex control connection closed: " withString:@"Rex 控制连接已关闭："];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex control connection sent an invalid message: " withString:@"Rex 控制连接发送了无效消息："];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex control request " withString:@"Rex 控制请求 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex server refused the connection because it doesn't support the API " withString:@"Rex 服务器拒绝连接，因为它不支持 API "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex server refused the connection because it doesn’t support the API " withString:@"Rex 服务器拒绝连接，因为它不支持 API "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"revisions this app needs (" withString:@"修订版，此应用需要（"];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"). Update Rex on the server or this app." withString:@"）。请更新服务器上的 Rex 或此应用。"];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex server refused the connection: " withString:@"Rex 服务器拒绝连接："];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"The Rex server supports API revisions " withString:@"Rex 服务器支持 API 修订版 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"This app can't send this " withString:@"此应用无法发送此 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"This app can’t send this " withString:@"此应用无法发送此 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@" request to a server that uses API revision " withString:@" 请求，服务器使用 API 修订版 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@". Update Rex on the server." withString:@"。请更新服务器上的 Rex。"];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"Update Rex on the server to use " withString:@"更新服务器上的 Rex 以使用 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"the server uses revision " withString:@"服务器使用修订版 "];
    controlAPIError = [controlAPIError stringByReplacingOccurrencesOfString:@"this app needs revisions " withString:@"此应用需要修订版 "];
    if (![controlAPIError isEqualToString:s]) return controlAPIError;
    if ([s hasPrefix:@"Signing out of Tailscale timed out. "]) return [NSString stringWithFormat:@"退出 Tailscale 超时。%@", [s substringFromIndex:[@"Signing out of Tailscale timed out. " length]]];
    if ([s hasPrefix:@"Changing Tailscale tags timed out. "]) return [NSString stringWithFormat:@"更改 Tailscale 标签超时。%@", [s substringFromIndex:[@"Changing Tailscale tags timed out. " length]]];
    if ([s hasPrefix:@"This app is older than Rex on "]) return [NSString stringWithFormat:@"此应用版本低于主机上的 Rex：%@", [s substringFromIndex:[@"This app is older than Rex on " length]]];
    if ([s hasPrefix:@"This device is offline. Restore your network connection, then retry connecting to "]) return [NSString stringWithFormat:@"此设备处于离线状态。请恢复网络连接，然后重试连接到 %@", [s substringFromIndex:[@"This device is offline. Restore your network connection, then retry connecting to " length]]];
    if ([s hasPrefix:@"Rex couldn’t start Tailscale to remove the saved login. "]) return [NSString stringWithFormat:@"Rex 无法启动 Tailscale 以移除保存的登录信息。%@", [s substringFromIndex:[@"Rex couldn’t start Tailscale to remove the saved login. " length]]];
    if ([s hasPrefix:@"Rex couldn't start Tailscale to remove the saved login. "]) return [NSString stringWithFormat:@"Rex 无法启动 Tailscale 以移除保存的登录信息。%@", [s substringFromIndex:[@"Rex couldn't start Tailscale to remove the saved login. " length]]];
    if ([s hasPrefix:@"Remove “"] && [s hasSuffix:@"”?"]) {
        return [NSString stringWithFormat:@"移除%@", [s substringFromIndex:[@"Remove " length]]];
    }
    if ([s hasPrefix:@"Remove '"] && [s hasSuffix:@"'?"]) {
        return [NSString stringWithFormat:@"移除%@", [s substringFromIndex:[@"Remove " length]]];
    }
    if ([s isEqualToString:@"theme"]) return @"主题";
    if ([s hasPrefix:@"Rex Beta Version "]) {
        return [NSString stringWithFormat:@"Rex Beta 版本 %@", [s substringFromIndex:[@"Rex Beta Version " length]]];
    }
    if ([s hasPrefix:@"Version "]) {
        return [NSString stringWithFormat:@"版本 %@", [s substringFromIndex:[@"Version " length]]];
    }
    if ([s hasPrefix:@"Copy "]) {
        NSString *suffix = [s substringFromIndex:[@"Copy " length]];
        return [NSString stringWithFormat:@"复制%@", RXTranslate(suffix)];
    }
    if ([s hasPrefix:@"Hex value for "]) {
        NSString *label = [s substringFromIndex:[@"Hex value for " length]];
        return [NSString stringWithFormat:@"%@的十六进制值", RXTranslate(label)];
    }
    if ([s hasPrefix:@"Black #"]) return [NSString stringWithFormat:@"黑色%@", [s substringFromIndex:[@"Black" length]]];
    if ([s hasPrefix:@"Red #"]) return [NSString stringWithFormat:@"红色%@", [s substringFromIndex:[@"Red" length]]];
    if ([s hasPrefix:@"Green #"]) return [NSString stringWithFormat:@"绿色%@", [s substringFromIndex:[@"Green" length]]];
    if ([s hasPrefix:@"Yellow #"]) return [NSString stringWithFormat:@"黄色%@", [s substringFromIndex:[@"Yellow" length]]];
    if ([s hasPrefix:@"Blue #"]) return [NSString stringWithFormat:@"蓝色%@", [s substringFromIndex:[@"Blue" length]]];
    if ([s hasPrefix:@"Magenta #"]) return [NSString stringWithFormat:@"品红色%@", [s substringFromIndex:[@"Magenta" length]]];
    if ([s hasPrefix:@"Cyan #"]) return [NSString stringWithFormat:@"青色%@", [s substringFromIndex:[@"Cyan" length]]];
    if ([s hasPrefix:@"White #"]) return [NSString stringWithFormat:@"白色%@", [s substringFromIndex:[@"White" length]]];
    if ([s hasPrefix:@"Bright Black #"]) return [NSString stringWithFormat:@"亮黑色%@", [s substringFromIndex:[@"Bright Black" length]]];
    if ([s hasPrefix:@"Bright Red #"]) return [NSString stringWithFormat:@"亮红色%@", [s substringFromIndex:[@"Bright Red" length]]];
    if ([s hasPrefix:@"Bright Green #"]) return [NSString stringWithFormat:@"亮绿色%@", [s substringFromIndex:[@"Bright Green" length]]];
    if ([s hasPrefix:@"Bright Yellow #"]) return [NSString stringWithFormat:@"亮黄色%@", [s substringFromIndex:[@"Bright Yellow" length]]];
    if ([s hasPrefix:@"Bright Blue #"]) return [NSString stringWithFormat:@"亮蓝色%@", [s substringFromIndex:[@"Bright Blue" length]]];
    if ([s hasPrefix:@"Bright Magenta #"]) return [NSString stringWithFormat:@"亮品红色%@", [s substringFromIndex:[@"Bright Magenta" length]]];
    if ([s hasPrefix:@"Bright Cyan #"]) return [NSString stringWithFormat:@"亮青色%@", [s substringFromIndex:[@"Bright Cyan" length]]];
    if ([s hasPrefix:@"Bright White #"]) return [NSString stringWithFormat:@"亮白色%@", [s substringFromIndex:[@"Bright White" length]]];
    if ([s hasSuffix:@" theme"]) {
        NSString *base = [s substringToIndex:s.length - [@" theme" length]];
        NSString *translatedBase = RXTranslate(base);
        if (translatedBase.length && ![translatedBase isEqualToString:base]) return [translatedBase stringByAppendingString:@"主题"];
    }
    if ([s hasPrefix:@"New Session "]) {
        return [NSString stringWithFormat:@"新建会话 %@", [s substringFromIndex:[@"New Session " length]]];
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
    if ([s containsString:@"Diagnostics"] || [s containsString:@"Rex Binary"] || [s containsString:@"Terminal Policy"] || [s containsString:@"JSON Payload"] || [s containsString:@"Shares are of one GPU"] || [s containsString:@"Scheme"] || [s containsString:@" recorded"] || [s containsString:@"Other Processes"]) {
        s = [s stringByReplacingOccurrencesOfString:@" – Diagnostics" withString:@" – 诊断"];
        s = [s stringByReplacingOccurrencesOfString:@" Diagnostics" withString:@" 诊断"];
        s = [s stringByReplacingOccurrencesOfString:@"Kind" withString:@"类型"];
        s = [s stringByReplacingOccurrencesOfString:@"Included with Rex.app" withString:@"随 Rex.app 附带"];
        s = [s stringByReplacingOccurrencesOfString:@"Live Logs" withString:@"实时日志"];
        s = [s stringByReplacingOccurrencesOfString:@"Stop Server" withString:@"停止服务器"];
        s = [s stringByReplacingOccurrencesOfString:@"Clear Logs" withString:@"清除日志"];
        s = [s stringByReplacingOccurrencesOfString:@"Show Inspector" withString:@"显示检查器"];
        s = [s stringByReplacingOccurrencesOfString:@"Invoke" withString:@"调用"];
        s = [s stringByReplacingOccurrencesOfString:@"JSON Payload" withString:@"JSON 负载"];
        s = [s stringByReplacingOccurrencesOfString:@"Method" withString:@"方法"];
        s = [s stringByReplacingOccurrencesOfString:@"Calls" withString:@"调用"];
        s = [s stringByReplacingOccurrencesOfString:@"Events" withString:@"事件"];
        s = [s stringByReplacingOccurrencesOfString:@"All Sessions" withString:@"所有会话"];
        s = [s stringByReplacingOccurrencesOfString:@" recorded" withString:@" 已记录"];
        s = [s stringByReplacingOccurrencesOfString:@"Terminal Policy" withString:@"终端策略"];
        s = [s stringByReplacingOccurrencesOfString:@"Scheme" withString:@"方案"];
        s = [s stringByReplacingOccurrencesOfString:@"Cursor Style" withString:@"光标样式"];
        s = [s stringByReplacingOccurrencesOfString:@"Cursor Blink" withString:@"光标闪烁"];
        s = [s stringByReplacingOccurrencesOfString:@"Option Key" withString:@"Option 键"];
        s = [s stringByReplacingOccurrencesOfString:@"Pending Changes" withString:@"待处理变更"];
        s = [s stringByReplacingOccurrencesOfString:@"Pending Pane Commands" withString:@"待处理窗格命令"];
        s = [s stringByReplacingOccurrencesOfString:@"Launch to First Drawable Frame" withString:@"启动到首个可绘制帧"];
        s = [s stringByReplacingOccurrencesOfString:@"Launch" withString:@"启动"];
        s = [s stringByReplacingOccurrencesOfString:@"Prewarm" withString:@"预热"];
        s = [s stringByReplacingOccurrencesOfString:@"Last Host" withString:@"上一个主机"];
        s = [s stringByReplacingOccurrencesOfString:@"Last Resume Failed" withString:@"上次恢复失败"];
        s = [s stringByReplacingOccurrencesOfString:@"Resumes" withString:@"恢复"];
        s = [s stringByReplacingOccurrencesOfString:@"Locators" withString:@"地址"];
        s = [s stringByReplacingOccurrencesOfString:@"Preferred URL" withString:@"首选 URL"];
        s = [s stringByReplacingOccurrencesOfString:@"Resolved Endpoint" withString:@"已解析端点"];
        s = [s stringByReplacingOccurrencesOfString:@"Instance Generation" withString:@"实例代次"];
        s = [s stringByReplacingOccurrencesOfString:@"Instance ID" withString:@"实例 ID"];
        s = [s stringByReplacingOccurrencesOfString:@"Host ID" withString:@"主机 ID"];
        s = [s stringByReplacingOccurrencesOfString:@"Client ID" withString:@"客户端 ID"];
        s = [s stringByReplacingOccurrencesOfString:@"Last Failure" withString:@"上次失败"];
        s = [s stringByReplacingOccurrencesOfString:@"Connection" withString:@"连接"];
        s = [s stringByReplacingOccurrencesOfString:@"Name" withString:@"名称"];
        s = [s stringByReplacingOccurrencesOfString:@"Icon" withString:@"图标"];
        s = [s stringByReplacingOccurrencesOfString:@"Sessions" withString:@"会话"];
        s = [s stringByReplacingOccurrencesOfString:@"Hosts" withString:@"主机"];
        s = [s stringByReplacingOccurrencesOfString:@"Migrated" withString:@"已迁移"];
        s = [s stringByReplacingOccurrencesOfString:@"Reset" withString:@"重置"];
        s = [s stringByReplacingOccurrencesOfString:@"Usage" withString:@"使用情况"];
        s = [s stringByReplacingOccurrencesOfString:@"Now" withString:@"当前"];
        s = [s stringByReplacingOccurrencesOfString:@"Mean" withString:@"平均"];
        s = [s stringByReplacingOccurrencesOfString:@"Peak" withString:@"峰值"];
        s = [s stringByReplacingOccurrencesOfString:@"Last 120 Seconds" withString:@"最近 120 秒"];
        s = [s stringByReplacingOccurrencesOfString:@"Other Processes" withString:@"其他进程"];
        s = [s stringByReplacingOccurrencesOfString:@"Shares are of one GPU's time over each one-second sample. WindowServer composites Rex's transparent terminals over the window's glass and blur, so terminal output that redraws often shows up there rather than under Rex. Other windows also add to WindowServer's share. Use script/gpu-usage.py to record the same counters from Terminal." withString:@"每个一秒采样点中的占比是单个 GPU 时间的占比。WindowServer 会将 Rex 的透明终端合成到窗口的玻璃和模糊效果上，因此经常重绘的终端输出通常会显示在 WindowServer 下，而不是 Rex 下。其他窗口也会增加 WindowServer 的占比。使用 script/gpu-usage.py 可从终端记录相同的计数器。"];
    }
    if ([s hasSuffix:@" recorded"]) {
        s = [[s substringToIndex:s.length - [@" recorded" length]] stringByAppendingString:@" 已记录"];
    }
    if (![s isEqualToString:original]) return s;
    NSString *remoteHostError = s;
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn’t connect to " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn't connect to " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn’t reach " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn't reach " withString:@"无法连接到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn’t find " withString:@"找不到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@"Couldn't find " withString:@"找不到 "];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@". Check your network connection and the host’s address, and make sure Rex is running on the host, then retry." withString:@"。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。"];
    remoteHostError = [remoteHostError stringByReplacingOccurrencesOfString:@". Check your network connection and the host's address, and make sure Rex is running on the host, then retry." withString:@"。请检查网络连接和主机地址，并确保主机上的 Rex 正在运行，然后重试。"];
    if (![remoteHostError isEqualToString:s]) return remoteHostError;
    if ([s hasPrefix:@"Check for Updates"]) return @"检查更新…";
    if ([s hasSuffix:@"、Running"]) return [NSString stringWithFormat:@"%@、运行中", [s substringToIndex:s.length - [@"、Running" length]]];
    if ([s hasPrefix:@"Running for "]) return [NSString stringWithFormat:@"已运行%@", [s substringFromIndex:[@"Running for " length]]];
    if ([s hasPrefix:@"Create a session on "]) {
        return [NSString stringWithFormat:@"在 %@ 上创建会话", RXTranslate([s substringFromIndex:[@"Create a session on " length]])];
    }
    if ([s hasPrefix:@"Reconnecting to "]) {
        return [NSString stringWithFormat:@"正在重新连接 %@", [s substringFromIndex:[@"Reconnecting to " length]]];
    }
    if ([s hasPrefix:@"Connecting to "]) {
        return [NSString stringWithFormat:@"正在连接 %@", [s substringFromIndex:[@"Connecting to " length]]];
    }
    if ([s hasPrefix:@"Connected to "]) {
        return [NSString stringWithFormat:@"已连接到 %@", [s substringFromIndex:[@"Connected to " length]]];
    }
    if ([s hasPrefix:@"Loading Sessions on "]) {
        return [NSString stringWithFormat:@"正在加载 %@ 上的会话", [s substringFromIndex:[@"Loading Sessions on " length]]];
    }
    if ([s hasPrefix:@"Exited with status "]) {
        return [NSString stringWithFormat:@"已退出，状态码 %@", [s substringFromIndex:[@"Exited with status " length]]];
    }
    if ([s hasPrefix:@"Connection warning for "]) {
        return [NSString stringWithFormat:@"连接警告：%@", RXTranslate([s substringFromIndex:[@"Connection warning for " length]])];
    }
    if ([s hasPrefix:@"Connection errors: "]) {
        return [NSString stringWithFormat:@"连接错误：%@", [s substringFromIndex:[@"Connection errors: " length]]];
    }
    if ([s hasPrefix:@"Tailscale failed: "]) {
        return [NSString stringWithFormat:@"Tailscale 失败：%@", [s substringFromIndex:[@"Tailscale failed: " length]]];
    }
    if ([s hasPrefix:@"Tailscale assigned "]) {
        return [NSString stringWithFormat:@"Tailscale 已分配 %@", [s substringFromIndex:[@"Tailscale assigned " length]]];
    }
    if ([s hasPrefix:@"Restart required: "]) {
        return [NSString stringWithFormat:@"需要重新启动：%@", [s substringFromIndex:[@"Restart required: " length]]];
    }
    if ([s hasPrefix:@"Restarted the Rex server for Rex "]) {
        return [NSString stringWithFormat:@"已为 Rex %@ 重新启动服务器", [s substringFromIndex:[@"Restarted the Rex server for Rex " length]]];
    }
    if ([s hasPrefix:@"Update Rex on the server to use "]) {
        return [NSString stringWithFormat:@"更新服务器上的 Rex 以使用 %@", [s substringFromIndex:[@"Update Rex on the server to use " length]]];
    }
    if ([s hasPrefix:@"Set Terminal Font Size to "]) {
        return [NSString stringWithFormat:@"将终端字体大小设为 %@", [s substringFromIndex:[@"Set Terminal Font Size to " length]]];
    }
    if ([s hasPrefix:@"Server Version "]) {
        NSString *translatedVersion = [s stringByReplacingOccurrencesOfString:@"Server Version" withString:@"服务器版本"];
        translatedVersion = [translatedVersion stringByReplacingOccurrencesOfString:@"API Version" withString:@"API 版本"];
        translatedVersion = [translatedVersion stringByReplacingOccurrencesOfString:@"Revision" withString:@"修订版"];
        return translatedVersion;
    }
    if ([s hasPrefix:@"Revision "]) {
        return [NSString stringWithFormat:@"修订版 %@", [s substringFromIndex:[@"Revision " length]]];
    }
    if ([s containsString:@"API 版本 Revision "]) {
        return [s stringByReplacingOccurrencesOfString:@"Revision " withString:@"修订版 "];
    }
    if ([s containsString:@"API Version Revision "]) {
        NSString *translatedVersion = [s stringByReplacingOccurrencesOfString:@"API Version" withString:@"API 版本"];
        return [translatedVersion stringByReplacingOccurrencesOfString:@"Revision " withString:@"修订版 "];
    }
    if ([s hasPrefix:@"登录 Tailscale、Access Rex securely from your other devices."]) return @"登录 Tailscale、从其他设备安全访问 Rex。";
    if ([s hasPrefix:@"Settings - "]) {
        return [NSString stringWithFormat:@"设置 - %@", RXTranslate([s substringFromIndex:[@"Settings - " length]])];
    }
    if ([s hasPrefix:@"Rex Server Running for "]) {
        return [NSString stringWithFormat:@"Rex 服务器已运行 %@", [s substringFromIndex:[@"Rex Server Running for " length]]];
    }
    NSRange serverMarker = [s rangeOfString:@"Rex Server Running for"];
    if (serverMarker.location != NSNotFound) {
        NSString *duration = [s substringFromIndex:serverMarker.location + serverMarker.length];
        return [NSString stringWithFormat:@"Rex 服务器已运行%@", duration];
    }
    if ([s hasPrefix:@"录制 "] && [s hasSuffix:@" 的快捷键"]) {
        NSString *suffix = @" 的快捷键";
        NSString *action = [s substringWithRange:NSMakeRange([@"录制 " length], s.length - [@"录制 " length] - suffix.length)];
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
        NSString *middle = [s substringWithRange:NSMakeRange([@"Move " length], s.length - [@"Move " length] - [@" pane" length])];
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

static IMP origTitle, origButtonTitleGetter, origMenuTitle, origMenuTitleGetter, origMenuAttributedTitle, origMenuAttributedTitleGetter, origMenuAccessibilityValue, origMenuAccessibilityLabel, origMenuAccessibilityTitle, origMenuAccessibilityDescription, origWindowTitle, origStringValue, origPlaceholder, origPlaceholderGetter, origAccessibilityLabel, origAccessibilityTitle, origAccessibilityHelp, origAccessibilityDescription, origToolTip, origAccessibilityValue, origSegmentAccessibilityValue, origSegmentAccessibilityDescription, origSegmentAccessibilityDescriptionAttribute, origConcreteSegmentAccessibilityValue, origToolbarViewerAccessibilityValue, origToolbarViewerDescriptionAttribute, origToolbarViewerTitleAttribute, origIndexedAssociatedLabel, origIndexedSetAssociatedLabel, origPopupTitleOfSelectedItem, origPopupCellTitle, origViewAccessibilityLabelGetter, origViewAccessibilityTitleGetter, origViewAccessibilityHelpGetter, origViewAccessibilityDescriptionGetter, origViewAccessibilityPlaceholderGetter, origViewAccessibilityValueGetter, origViewAccessibilityValueDescriptionGetter, origViewAccessibilityRoleDescriptionGetter, origButtonAccessibilityLabel, origButtonAccessibilityTitle, origButtonAccessibilityHelp, origButtonAccessibilityDescription, origToolbarItemLabel, origToolbarItemLabelGetter, origToolbarItemPaletteLabel, origToolbarItemPaletteLabelGetter, origToolbarItemToolTip, origToolbarItemToolTipGetter, origBundleLocalized, origSplitChildren, origSplitters, origCellStringValue, origCellSetStringValue, origCellAccessibilityLabel, origCellAccessibilityTitle, origCellAccessibilityHelp, origCellAccessibilityValue, origSwiftLabel, origSwiftHelp, origSwiftDescription, origSwiftAttribute, origSwiftValue, origSwiftValueDescription, origSwiftRoleDescription, origSwiftPlaceholder, origSwiftAttributedLabel;
static IMP origAXElementAttribute, origAXElementValue, origAXElementPlaceholder, origAXElementLabel, origAXElementTitle, origAXElementHelp, origAXElementDescription, origAXElementRoleDescription;
static IMP origMockAccessibilityAttribute;
static IMP origAttributedPlaceholder, origCellPlaceholder, origCellAttributedPlaceholder;
// Editable values are user input. Placeholder/label translation must never
// turn a query or command such as "Filter" into the matching UI translation.
static BOOL RXIsEditableTextObject(id object) {
    if ([object isKindOfClass:[NSTextField class]]) return [(NSTextField *)object isEditable];
    if ([object isKindOfClass:[NSTextView class]]) return [(NSTextView *)object isEditable];
    if ([object isKindOfClass:[NSTextFieldCell class]]) return [(NSTextFieldCell *)object isEditable];
    return NO;
}
static __thread BOOL RXInAXElementHook;
// AppKit's private toolbar accessibility providers can ask for an attribute
// while resolving the value of that same attribute. The segment hooks below
// must not re-enter one another through NSAccessibility's legacy bridge.
static __thread BOOL RXInSegmentAXHook;
static NSMutableDictionary *RXPopupOriginals;
static NSMutableDictionary *RXMenuItemOriginals;
static NSWindow *RXAXWalkWindow;
static NSRect RXDefaultShellFrame;
static BOOL RXHasDefaultShellFrame;
static NSRect RXNotificationFrame;
static BOOL RXHasNotificationFrame;
static NSString *RXNotificationPositionText;
static NSRect RXRemoteHeaderFrame;
static BOOL RXHasRemoteHeaderFrame;
static NSRect RXServerAccessFrame;
static BOOL RXHasServerAccessFrame;
static NSRect RXRemoteSaveFrame;
static BOOL RXHasRemoteSaveFrame;
static NSRect RXThemeEditorNameFrame;
static BOOL RXHasThemeEditorNameFrame;
// The native SwiftUI color picker renders these three labels outside the
// normal Text/AX hooks. Keep their frames so the visual overlay can replace
// the English labels without touching the picker controls themselves.
static NSRect RXHueFrame;
static NSRect RXChromaFrame;
static NSRect RXLightnessFrame;
static BOOL RXHasHueFrame;
static BOOL RXHasChromaFrame;
static BOOL RXHasLightnessFrame;
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
    if (RXInSegmentAXHook) {
        return origSegmentAccessibilityDescription ? ((NSString *(*)(id, SEL))origSegmentAccessibilityDescription)(self, _cmd) : nil;
    }
    RXInSegmentAXHook = YES;
    NSString *value = origSegmentAccessibilityDescription ? ((NSString *(*)(id, SEL))origSegmentAccessibilityDescription)(self, _cmd) : nil;
    RXInSegmentAXHook = NO;
    return RXTranslate(value);
}
static NSString *RXSegmentAccessibilityDescriptionAttribute(id self, SEL _cmd) {
    // Returning nil for a re-entrant lookup breaks the AppKit legacy bridge's
    // cycle while allowing the outer request to continue normally.
    if (RXInSegmentAXHook) return nil;
    RXInSegmentAXHook = YES;
    NSString *value = origSegmentAccessibilityDescriptionAttribute ? ((NSString *(*)(id, SEL))origSegmentAccessibilityDescriptionAttribute)(self, _cmd) : nil;
    RXInSegmentAXHook = NO;
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
static id RXConcreteSegmentAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    if (RXInSegmentAXHook) {
        return origConcreteSegmentAccessibilityValue ? ((id (*)(id, SEL, NSString *))origConcreteSegmentAccessibilityValue)(self, _cmd, attribute) : nil;
    }
    RXInSegmentAXHook = YES;
    id value = origConcreteSegmentAccessibilityValue ? ((id (*)(id, SEL, NSString *))origConcreteSegmentAccessibilityValue)(self, _cmd, attribute) : nil;
    RXInSegmentAXHook = NO;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"ConcreteSegment %@", attribute]);
    if ([value isKindOfClass:[NSString class]] &&
        ([attribute isEqualToString:NSAccessibilityTitleAttribute] ||
         [attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityHelpAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute])) return RXTranslate(value);
    return value;
}
static id RXToolbarViewerAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    if (RXInSegmentAXHook) {
        return origToolbarViewerAccessibilityValue ? ((id (*)(id, SEL, NSString *))origToolbarViewerAccessibilityValue)(self, _cmd, attribute) : nil;
    }
    RXInSegmentAXHook = YES;
    id value = origToolbarViewerAccessibilityValue ? ((id (*)(id, SEL, NSString *))origToolbarViewerAccessibilityValue)(self, _cmd, attribute) : nil;
    RXInSegmentAXHook = NO;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"ToolbarViewer %@", attribute]);
    if ([value isKindOfClass:[NSString class]] &&
        ([attribute isEqualToString:NSAccessibilityTitleAttribute] ||
         [attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityHelpAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute])) return RXTranslate(value);
    return value;
}
static NSString *RXIndexedAssociatedLabel(id self, SEL _cmd) {
    NSString *value = origIndexedAssociatedLabel ? ((NSString *(*)(id, SEL))origIndexedAssociatedLabel)(self, _cmd) : nil;
    RXDebugTranslation(self, _cmd, value, @"Indexed associated label");
    return RXTranslate(value);
}
static void RXIndexedSetAssociatedLabel(id self, SEL _cmd, NSString *value) {
    if (origIndexedSetAssociatedLabel) ((void (*)(id, SEL, NSString *))origIndexedSetAssociatedLabel)(self, _cmd, RXTranslate(value));
}
static id RXMockAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    if (RXInSegmentAXHook) return origMockAccessibilityAttribute ? ((id (*)(id, SEL, NSString *))origMockAccessibilityAttribute)(self, _cmd, attribute) : nil;
    RXInSegmentAXHook = YES;
    id value = origMockAccessibilityAttribute ? ((id (*)(id, SEL, NSString *))origMockAccessibilityAttribute)(self, _cmd, attribute) : nil;
    RXInSegmentAXHook = NO;
    RXDebugTranslation(self, _cmd, value, [NSString stringWithFormat:@"Mock %@", attribute]);
    if ([value isKindOfClass:[NSString class]] &&
        ([attribute isEqualToString:NSAccessibilityTitleAttribute] ||
         [attribute isEqualToString:NSAccessibilityDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityHelpAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueAttribute] ||
         [attribute isEqualToString:NSAccessibilityValueDescriptionAttribute] ||
         [attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute])) return RXTranslate(value);
    return value;
}
static id RXSegmentAccessibilityAttributeValue(id self, SEL _cmd, NSString *attribute) {
    IMP original = origSegmentAccessibilityValue ? origSegmentAccessibilityValue : (origAXElementAttribute ? origAXElementAttribute : origAccessibilityValue);
    if (RXInSegmentAXHook) {
        return original ? ((id (*)(id, SEL, NSString *))original)(self, _cmd, attribute) : nil;
    }
    RXInSegmentAXHook = YES;
    id value = original ? ((id (*)(id, SEL, NSString *))original)(self, _cmd, attribute) : nil;
    RXInSegmentAXHook = NO;
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
    return RXIsEditableTextObject(self) ? value : RXTranslate(value);
}
static void RXCellSetStringValue(id self, SEL _cmd, NSString *value) {
    if (origCellSetStringValue) ((void (*)(id, SEL, NSString *))origCellSetStringValue)(self, _cmd, RXIsEditableTextObject(self) ? value : RXTranslate(value));
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
    ((void (*)(id, SEL, NSString *))origStringValue)(self, _cmd, RXIsEditableTextObject(self) ? value : RXTranslate(value));
}
static void RXSetPlaceholder(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origPlaceholder)(self, _cmd, RXTranslate(value));
}
static NSString *RXPlaceholder(id self, SEL _cmd) {
    NSString *value = origPlaceholderGetter ? ((NSString *(*)(id, SEL))origPlaceholderGetter)(self, _cmd) : nil;
    return RXTranslate(value);
}
static void RXSetAttributedPlaceholder(id self, SEL _cmd, NSAttributedString *value) {
    ((void (*)(id, SEL, NSAttributedString *))origAttributedPlaceholder)(self, _cmd, RXTranslatedAttributedString(value));
}
static void RXSetCellPlaceholder(id self, SEL _cmd, NSString *value) {
    ((void (*)(id, SEL, NSString *))origCellPlaceholder)(self, _cmd, RXTranslate(value));
}
static void RXSetCellAttributedPlaceholder(id self, SEL _cmd, NSAttributedString *value) {
    ((void (*)(id, SEL, NSAttributedString *))origCellAttributedPlaceholder)(self, _cmd, RXTranslatedAttributedString(value));
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
    if (RXIsEditableTextObject(self)) return value;
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
    if ([attribute isEqualToString:NSAccessibilityValueAttribute] && RXIsEditableTextObject(self)) return value;
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
    if ([attribute isEqualToString:NSAccessibilityValueAttribute] && RXIsEditableTextObject(self)) return value;
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
    if (textView.isEditable) return;
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
    if (origNSTextViewSetString) ((void (*)(id, SEL, NSString *))origNSTextViewSetString)(self, _cmd, RXIsEditableTextObject(self) ? value : RXTranslate(value));
}

static void RXTextFieldTextViewDraw(id self, SEL _cmd, NSRect rect) {
    if (origTextFieldTextViewDraw) ((void (*)(id, SEL, NSRect))origTextFieldTextViewDraw)(self, _cmd, rect);
    if (RXIsEditableTextObject(self)) return;
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

static void RXTranslateAXNode(id element);
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
        // Repair existing storage through the control setter so AppKit also
        // invalidates its private placeholder label, rather than only the cell.
        NSTextFieldCell *cell = field.cell;
        if ([cell isKindOfClass:[NSTextFieldCell class]]) {
            NSString *placeholder = cell.placeholderString;
            NSString *translated = RXTranslate(placeholder);
            if (translated.length && ![translated isEqualToString:placeholder]) {
                field.placeholderString = translated;
                [field setNeedsDisplay:YES];
            }
            NSAttributedString *attributed = cell.placeholderAttributedString;
            NSAttributedString *translatedAttributed = RXTranslatedAttributedString(attributed);
            if (translatedAttributed != attributed) {
                field.placeholderAttributedString = translatedAttributed;
                [field setNeedsDisplay:YES];
            }
        }
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
    // Native views are already visited through subviews. Inspect only their
    // own AX attributes here: recursively walking each view's AX subtree
    // repeats every descendant once per ancestor and starves the main loop.
    if ([view isKindOfClass:[NSControl class]]) { NSCell *cell = [(NSControl *)view cell]; if (cell) RXTranslateAXNode(cell); }
    RXTranslateAXNode(view);
    for (NSView *child in view.subviews) RXWalk(child);
}

@interface RXResidualOverlayView : NSView
@property(nonatomic, copy) NSString *text;
@property(nonatomic) CGFloat fontSize;
@property(nonatomic) BOOL settingsSubtitle;
@end

@implementation RXResidualOverlayView
- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (NSView *)hitTest:(NSPoint)point { (void)point; return nil; }
- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    // The 0.1.0 settings card uses a subtle fill; controlColor is solid white
    // in Aqua and produced a visible white bar over the translated subtitle.
    // These fills match 0.1.0's default Merino/Classic cards in both appearances.
    BOOL dark = [[self.effectiveAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]] isEqualToString:NSAppearanceNameDarkAqua];
    NSColor *background = self.settingsSubtitle ? [NSColor colorWithSRGBRed:dark ? 0.101085 : 0.956254
        green:dark ? 0.113529 : 0.956254 blue:dark ? 0.135443 : 0.956254 alpha:1.0] : NSColor.controlBackgroundColor;
    [[background colorWithAlphaComponent:1.0] setFill];
    NSRectFill(self.bounds);
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont systemFontOfSize:self.fontSize > 0.0 ? self.fontSize : 16.0],
        NSForegroundColorAttributeName: NSColor.secondaryLabelColor
    };
    [self.text drawAtPoint:NSMakePoint(0.0, 1.0) withAttributes:attributes];
}
@end

// SwiftUI's ColorPicker uses private controls for the Hue/Chroma/Lightness
// labels. They are visible in the rendered popover but are not exposed as
// ordinary Text views, so draw the translated labels over their exact AX
// frames. The overlay is transparent to mouse hit testing.
static void RXSetColorPickerLabelOverlay(NSWindow *window, NSString *key, NSString *text, NSRect screenFrame);

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
        if ([subview isKindOfClass:[RXResidualOverlayView class]]) {
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
    if (window.title.length) return;
    if (size.width >= 450.0 && size.width <= 600.0 && size.height >= 400.0 && size.height <= 600.0) {
        BOOL flipped = window.contentView.isFlipped;
        NSRect headerFrame = flipped ? NSMakeRect(72.0, 18.0, size.width - 130.0, 78.0) : NSMakeRect(72.0, size.height - 96.0, size.width - 130.0, 78.0);
        NSRect saveFrame = flipped ? NSMakeRect(size.width - 82.0, size.height - 52.0, 70.0, 38.0) : NSMakeRect(size.width - 82.0, 14.0, 70.0, 38.0);
        RXSetLocalRuntimeOverlayView(window, @"rex-remote-host-header-fixed", [RXRemoteHostHeaderOverlayView class], headerFrame);
        RXSetLocalRuntimeOverlayView(window, @"rex-remote-host-save-fixed", [RXRemoteHostSaveOverlayView class], saveFrame);
        return;
    }
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

static void RXSetColorPickerLabelOverlay(NSWindow *window, NSString *key, NSString *text, NSRect screenFrame) {
    if (!window || !window.contentView || NSIsEmptyRect(screenFrame)) return;
    NSView *host = window.contentView;
    NSRect windowFrame = [window convertRectFromScreen:screenFrame];
    NSRect frame = [host convertRect:windowFrame fromView:nil];
    RXResidualOverlayView *overlay = nil;
    for (NSView *subview in host.subviews) {
        if ([subview isKindOfClass:[RXResidualOverlayView class]] && [subview.identifier isEqualToString:key]) {
            overlay = (RXResidualOverlayView *)subview;
            break;
        }
    }
    if (!overlay) {
        overlay = [[RXResidualOverlayView alloc] initWithFrame:frame];
        overlay.identifier = key;
        [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    }
    if (!RXOwnedResidualOverlays) RXOwnedResidualOverlays = [NSHashTable weakObjectsHashTable];
    [RXOwnedResidualOverlays addObject:overlay];
    overlay.wantsLayer = YES;
    overlay.layer.zPosition = 1000.0;
    overlay.text = text;
    overlay.frame = frame;
    overlay.hidden = NO;
    [overlay setNeedsDisplay:YES];
}

static void RXRemoveColorPickerLabelOverlays(NSWindow *window) {
    if (!window || !window.contentView) return;
    for (NSView *subview in [window.contentView.subviews copy]) {
        if (![subview isKindOfClass:[RXResidualOverlayView class]]) continue;
        NSString *identifier = subview.identifier;
        if ([identifier isEqualToString:@"rex-color-picker-hue"] ||
            [identifier isEqualToString:@"rex-color-picker-chroma"] ||
            [identifier isEqualToString:@"rex-color-picker-lightness"]) {
            [subview removeFromSuperview];
        }
    }
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
    if (RXHasHueFrame) RXSetColorPickerLabelOverlay(window, @"rex-color-picker-hue", @"色相", RXHueFrame);
    if (RXHasChromaFrame) RXSetColorPickerLabelOverlay(window, @"rex-color-picker-chroma", @"色度", RXChromaFrame);
    if (RXHasLightnessFrame) RXSetColorPickerLabelOverlay(window, @"rex-color-picker-lightness", @"亮度", RXLightnessFrame);
    if (!RXHasHueFrame && !RXHasChromaFrame && !RXHasLightnessFrame) RXRemoveColorPickerLabelOverlays(window);
    RXSetAboutOverlay(window);
    if (!window.title.length && RXHasThemeEditorNameFrame) RXSetThemeEditorNameOverlay(window, YES);
    else if (!window.title.length) RXSetThemeEditorNameOverlay(window, NO);
    if (!window.title.length && window.frame.size.width >= 580.0 && window.frame.size.width <= 650.0 && window.frame.size.height >= 560.0 && window.frame.size.height <= 630.0) {
        RXTranslateThemeEditorNameInView(window.contentView);
    }
    if (RXHasRemoteHeaderFrame) RXSetRuntimeOverlayView(window, @"rex-remote-host-header", [RXRemoteHostHeaderOverlayView class], RXRemoteHeaderFrame);
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
    if ([key isEqualToString:@"rex-server-access"] || [key isEqualToString:@"rex-notification-position"]) {
        overlay.fontSize = 11.0;
        overlay.settingsSubtitle = YES;
    }
    [host addSubview:overlay positioned:NSWindowAbove relativeTo:nil];
    [overlay setNeedsDisplay:YES];
}

static NSRect RXAccessibilityFrame(id element) {
    SEL selector = @selector(accessibilityFrame);
    if ([element respondsToSelector:selector]) {
        // Let Clang select objc_msgSend_stret for the 32-byte NSRect return
        // on x86_64; casting objc_msgSend directly only works on arm64.
        NSRect frame = [element accessibilityFrame];
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

static BOOL RXCollectNotificationPosition(id element, NSUInteger depth) {
    if (!element || depth > 20 || RXIsOwnedOverlayObject(element)) return NO;
    // SwiftUI's subtitle is exposed through the modern AX getters, but not
    // consistently through accessibilityAttributeValue: during the legacy
    // walk. Read the same modern tree used by the external AX client.
    id value = [element respondsToSelector:@selector(accessibilityValue)] ?
        ((id (*)(id, SEL))objc_msgSend)(element, @selector(accessibilityValue)) : nil;
    NSString *text = [value isKindOfClass:[NSString class]] ? RXTranslate(value) : nil;
    if (text && [@[@"显示在左上角", @"显示在顶部居中", @"显示在右上角", @"显示在左下角", @"显示在底部居中", @"显示在右下角"] containsObject:text]) {
        NSRect frame = RXAccessibilityFrame(element);
        if (!NSIsEmptyRect(frame)) {
            RXNotificationFrame = frame;
            RXNotificationPositionText = text;
            RXHasNotificationFrame = YES;
            return YES;
        }
    }
    id children = [element respondsToSelector:@selector(accessibilityChildren)] ?
        ((id (*)(id, SEL))objc_msgSend)(element, @selector(accessibilityChildren)) : nil;
    if ([children isKindOfClass:[NSArray class]]) {
        for (id child in children) if (RXCollectNotificationPosition(child, depth + 1)) return YES;
    }
    return NO;
}

static BOOL RXCollectServerAccessFrame(id element, NSUInteger depth) {
    if (!element || depth > 20 || RXIsOwnedOverlayObject(element)) return NO;
    // This SwiftUI card is present in the modern AX tree but can be omitted
    // from a window's legacy AXChildren. Find its real frame through the same
    // modern tree used by external accessibility clients.
    SEL selectors[] = { @selector(accessibilityLabel), @selector(accessibilityHelp),
                        @selector(accessibilityDescription), @selector(accessibilityValue) };
    for (NSUInteger i = 0; i < sizeof(selectors) / sizeof(selectors[0]); i++) {
        if (![element respondsToSelector:selectors[i]]) continue;
        id value = ((id (*)(id, SEL))objc_msgSend)(element, selectors[i]);
        if (![value isKindOfClass:[NSString class]]) continue;
        NSString *translated = RXTranslate(value);
        if (![translated containsString:@"从其他设备安全访问 Rex。"]) continue;
        NSRect frame = RXAccessibilityFrame(element);
        if (NSIsEmptyRect(frame)) continue;
        // The combined title/subtitle frame has a bottom-left origin.
        if (frame.size.height > 22.0) frame.size.height = 14.0;
        RXServerAccessFrame = frame;
        RXHasServerAccessFrame = YES;
        return YES;
    }
    id children = [element respondsToSelector:@selector(accessibilityChildren)] ?
        ((id (*)(id, SEL))objc_msgSend)(element, @selector(accessibilityChildren)) : nil;
    if ([children isKindOfClass:[NSArray class]]) {
        for (id child in children) if (RXCollectServerAccessFrame(child, depth + 1)) return YES;
    }
    return NO;
}

static NSString *RXSettingsToolbarPage(id element, NSUInteger depth) {
    if (!element || depth > 12 || RXIsOwnedOverlayObject(element)) return nil;
    NSString *label = [element respondsToSelector:@selector(accessibilityLabel)] ? [element accessibilityLabel] : nil;
    if ([label isEqualToString:@"设置页面"] || [label isEqualToString:@"Settings page"]) {
        id value = [element respondsToSelector:@selector(accessibilityValue)] ? [element accessibilityValue] : nil;
        if ([value isKindOfClass:[NSString class]]) return RXTranslate(value);
    }
    id children = [element respondsToSelector:@selector(accessibilityChildren)] ? [element accessibilityChildren] : nil;
    if ([children isKindOfClass:[NSArray class]]) {
        for (id child in children) {
            NSString *page = RXSettingsToolbarPage(child, depth + 1);
            if (page.length) return page;
        }
    }
    return nil;
}

static NSString *RXSettingsPage(NSWindow *window) {
    for (NSToolbarItem *item in window.toolbar.items) {
        NSString *page = RXSettingsToolbarPage(item.view, 0);
        if (page.length) return page;
    }
    return window.title ?: @"";
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
    NSString *page = RXSettingsPage(window);
    BOOL server = [page containsString:@"服务器"] || [page containsString:@"Server"];
    BOOL notifications = [page containsString:@"通知"] || [page containsString:@"Notifications"];
    BOOL terminal = [page containsString:@"终端"] || [page containsString:@"Terminal"];
    // A cold settings window can retain the generic title before SwiftUI
    // exposes its toolbar breadcrumb. The visible server card is unambiguous.
    if (!server && ([page isEqualToString:@"设置"] || [page isEqualToString:@"Settings"])) {
        server = RXCollectServerAccessFrame(window, 0);
    }
    // SwiftUI replaces the detail subtree while navigating. Remove stale overlays
    // before adding only the overlay that belongs to the visible page.
    if (server) {
        RXCollectServerAccessFrame(window, 0);
        // This SwiftUI subtitle is rendered outside the normal text hooks on
        // some Rex builds. Prefer its live AX frame; keep the fixed fallback
        // for builds that do not expose the node.
        if (RXHasServerAccessFrame) {
            RXSetWindowResidualOverlay(window, @"rex-server-access", @"从其他设备安全访问 Rex。", RXServerAccessFrame);
        } else {
            RXSetResidualOverlay(detail, @"rex-server-access", @"从其他设备安全访问 Rex。", NSMakeRect(74.0, 604.0, 430.0, 25.0), NO);
        }
    }
    if (notifications) {
        RXCollectNotificationPosition(window, 0);
        if (RXHasNotificationFrame) {
            RXSetWindowResidualOverlay(window, @"rex-notification-position", RXNotificationPositionText, RXNotificationFrame);
        }
    }
    if (terminal) {
        // The GPU preview sample is patched in RexCore's guarded __cstring
        // constant, preserving its real font, colors, and scrolling behavior.
        if (RXHasDefaultShellFrame) RXSetWindowResidualOverlay(window, @"rex-default-login-shell", @"默认登录 Shell", RXDefaultShellFrame);
    }
}

static void RXTranslateAXNode(id element) {
    if (!element || ![element respondsToSelector:@selector(accessibilityAttributeValue:)]) return;
    if (RXIsOwnedOverlayObject(element)) return;
    NSArray *attrs = @[NSAccessibilityDescriptionAttribute, NSAccessibilityTitleAttribute, NSAccessibilityHelpAttribute, NSAccessibilityPlaceholderValueAttribute, NSAccessibilityValueAttribute, NSAccessibilityValueDescriptionAttribute, NSAccessibilityRoleDescriptionAttribute];
    for (NSString *attribute in attrs) {
        if ([attribute isEqualToString:NSAccessibilityValueAttribute] && RXIsEditableTextObject(element)) continue;
        id value = [element accessibilityAttributeValue:attribute];
        if ([value isKindOfClass:[NSString class]]) {
            id rawObject = RXRawAXValue(element, attribute);
            NSString *rawValue = [rawObject isKindOfClass:[NSString class]] ? rawObject : value;
            NSString *translated = RXTranslate(value);
            NSRect rawFrame = RXAccessibilityFrame(element);
            if ([rawValue containsString:@"Access Rex securely from your other devices."] ||
                [value containsString:@"Access Rex securely from your other devices."] ||
                [translated containsString:@"从其他设备安全访问 Rex。"]) {
                // The combined AX label includes the title and subtitle.
                // AppKit screen frames use a bottom-left origin: keep only
                // the subtitle line at the bottom of this combined frame.
                if (rawFrame.size.height > 22.0) rawFrame.size.height = 14.0;
                RXServerAccessFrame = rawFrame;
                RXHasServerAccessFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue isEqualToString:@"Hue"]) {
                RXHueFrame = rawFrame;
                RXHasHueFrame = !NSIsEmptyRect(rawFrame);
            } else if ([rawValue isEqualToString:@"Chroma"]) {
                RXChromaFrame = rawFrame;
                RXHasChromaFrame = !NSIsEmptyRect(rawFrame);
            } else if ([rawValue isEqualToString:@"Lightness"]) {
                RXLightnessFrame = rawFrame;
                RXHasLightnessFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue isEqualToString:@"Untitled Light Theme"] || [rawValue isEqualToString:@"**Untitled Light Theme**"]) {
                RXThemeEditorNameFrame = rawFrame;
                RXHasThemeEditorNameFrame = !NSIsEmptyRect(rawFrame);
            }
            if ([rawValue containsString:@"Edit Host"] || [rawValue containsString:@"Changes are saved locally on this Mac."]) {
                RXRemoteHeaderFrame = rawFrame;
                RXHasRemoteHeaderFrame = !NSIsEmptyRect(rawFrame);
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
            if ([@[@"显示在左上角", @"显示在顶部居中", @"显示在右上角", @"显示在左下角", @"显示在底部居中", @"显示在右下角"] containsObject:translated]) {
                // AX getters can already return the translation while SwiftUI
                // still draws the original subtitle. Track either form.
                RXNotificationFrame = rawFrame;
                RXHasNotificationFrame = !NSIsEmptyRect(rawFrame);
                RXNotificationPositionText = translated;
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
}

static void RXWalkAX(id element, NSUInteger depth) {
    if (!element || depth > 20 || ![element respondsToSelector:@selector(accessibilityAttributeValue:)]) return;
    if (RXIsOwnedOverlayObject(element)) return;
    RXTranslateAXNode(element);
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
    Class mockClass = objc_getClass("NSAccessibilityMockUIElement");
    if (mockClass) origMockAccessibilityAttribute = RXHook(mockClass, @selector(accessibilityAttributeValue:), (IMP)RXMockAccessibilityAttributeValue);
    origSegmentAccessibilityValue = RXHook(segmentClass, @selector(accessibilityAttributeValue:), (IMP)RXSegmentAccessibilityAttributeValue);
    origSegmentAccessibilityDescription = RXHook(segmentClass, @selector(accessibilityDescription), (IMP)RXSegmentAccessibilityDescription);
    Class concreteSegmentClass = objc_getClass("NSAccessibilitySegment");
    if (concreteSegmentClass) {
        origConcreteSegmentAccessibilityValue = RXHook(concreteSegmentClass, @selector(accessibilityAttributeValue:), (IMP)RXConcreteSegmentAccessibilityAttributeValue);
        origSegmentAccessibilityDescriptionAttribute = RXHook(concreteSegmentClass, @selector(accessibilityDescriptionAttribute), (IMP)RXSegmentAccessibilityDescriptionAttribute);
    }
    Class indexedClass = objc_getClass("NSAccessibilityIndexedMockUIElement");
    if (indexedClass) {
        origIndexedAssociatedLabel = RXHook(indexedClass, @selector(associatedAccessibilityLabel), (IMP)RXIndexedAssociatedLabel);
        origIndexedSetAssociatedLabel = RXHook(indexedClass, @selector(setAssociatedAccessibilityLabel:), (IMP)RXIndexedSetAssociatedLabel);
    }
    Class toolbarViewerClass = objc_getClass("NSToolbarItemViewer");
    if (toolbarViewerClass) {
        origToolbarViewerAccessibilityValue = RXHook(toolbarViewerClass, @selector(accessibilityAttributeValue:), (IMP)RXToolbarViewerAccessibilityAttributeValue);
        origToolbarViewerDescriptionAttribute = RXHook(toolbarViewerClass, @selector(accessibilityDescriptionAttribute), (IMP)RXToolbarViewerDescriptionAttribute);
        origToolbarViewerTitleAttribute = RXHook(toolbarViewerClass, @selector(accessibilityTitleAttribute), (IMP)RXToolbarViewerTitleAttribute);
    }
}

static void RXRefreshAccessibility(void) {
    // Setters/interposed constructors translate new text synchronously. The
    // expensive class discovery and existing native-control repair are a
    // fallback; AX frames and transient overlays still refresh every tick.
    static NSTimeInterval lastNativeRefresh = -1.0;
    static NSHashTable *visitedWindows;
    NSTimeInterval now = NSProcessInfo.processInfo.systemUptime;
    BOOL refreshNative = lastNativeRefresh < 0.0 || now - lastNativeRefresh >= 1.0;
    if (refreshNative) {
        lastNativeRefresh = now;
        RXInstallMenuItemHooks();
        RXInstallSwiftNodeHooks();
        RXInstallPopupHooks();
        RXInstallSegmentHooks();
    }
    if (!visitedWindows) visitedWindows = [NSHashTable weakObjectsHashTable];
    for (NSWindow *window in NSApp.windows) {
        // SwiftUI retains closed settings windows and their large view trees.
        // Setter hooks still cover new content; poll only displayed windows.
        if (!window.isVisible) continue;
        RXHasDefaultShellFrame = NO;
        RXHasNotificationFrame = NO;
        RXNotificationPositionText = nil;
        RXHasRemoteHeaderFrame = NO;
        RXHasServerAccessFrame = NO;
        RXHasRemoteSaveFrame = NO;
        RXHasThemeEditorNameFrame = NO;
        RXThemeEditorNameFrame = NSZeroRect;
        RXHasHueFrame = NO;
        RXHasChromaFrame = NO;
        RXHasLightnessFrame = NO;
        RXHueFrame = NSZeroRect;
        RXChromaFrame = NSZeroRect;
        RXLightnessFrame = NSZeroRect;
        RXServerAccessFrame = NSZeroRect;
        RXAXWalkWindow = window;
        RXRefreshToolbar(window.toolbar);
        BOOL firstVisit = ![visitedWindows containsObject:window];
        if (refreshNative || firstVisit) {
            RXWalk(window.contentView);
            [visitedWindows addObject:window];
        }
        NSString *title = window.title ?: @"";
        BOOL settings = [title hasPrefix:@"设置"] || [title hasPrefix:@"Settings"];
        NSString *page = settings ? RXSettingsPage(window) : title;
        BOOL liveFrames = !title.length || (settings &&
            ([page containsString:@"服务器"] || [page containsString:@"Server"] ||
             [page containsString:@"通知"] || [page containsString:@"Notifications"] ||
             [page containsString:@"终端"] || [page containsString:@"Terminal"]));
        // Other windows have no frame-based overlays. Their existing AX
        // storage shares the native fallback cadence; getter hooks still
        // translate every accessibility read synchronously.
        if (refreshNative || firstVisit || liveFrames) RXWalkAX(window, 0);
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
        origAttributedPlaceholder = RXHook([NSTextField class], @selector(setPlaceholderAttributedString:), (IMP)RXSetAttributedPlaceholder);
        origCellPlaceholder = RXHook([NSTextFieldCell class], @selector(setPlaceholderString:), (IMP)RXSetCellPlaceholder);
        origCellAttributedPlaceholder = RXHook([NSTextFieldCell class], @selector(setPlaceholderAttributedString:), (IMP)RXSetCellAttributedPlaceholder);
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
            // Refresh the dynamic overlays on the common run-loop modes so
            // popovers and menus do not leave an English frame visible for
            // the old two-second polling interval. The same timer also keeps
            // the command-palette and text-field hooks installed as views are
            // created lazily by SwiftUI.
            NSTimer *timer = [NSTimer timerWithTimeInterval:0.2 repeats:YES block:^(NSTimer *timer) {
                RXInstallCommandPaletteHooks();
                RXInstallTextFieldTextViewHook();
                RXRefreshAccessibility();
            }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        });
    }
}
