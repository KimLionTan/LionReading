# LionReading
This is TanJianing's final project and no commercial use can be admitted
开发者安装指南
1. 概述
LionReading是一款基于iOS平台开发的app，用于帮助阅读者们个性化管理阅读书籍并获取相关推荐。此项目是需要在Xcode环境下运行的源代码项目，所支持的最低iOS版本是iOS 17.4，使用Swift 5语言开发，推荐使用Xcode 15或更高版本进行编译和运行。
2. 系统要求
操作系统: macOS Sonoma (14.0)或更高版本 
开发环境: Xcode 15.2或更高版本 
处理器: Apple Silicon(M1/M2/M3)或Intel i5/i7处理器 
测试环境：在搭载M2芯片、16GB RAM的MacBook Air上开发测试通过
模拟器兼容性: 已在iPhone 16 Pro模拟器上测试通过，运行iOS 17.4 
框架依赖: EventKit框架，SQLite依赖 
隐私权限要求: 日历访问权限(完全访问)，相机访问权限(有请求，但在模拟器中无法验证)
3. 安装准备
获取源代码：从证明文件中获取LionReading压缩包并解压。或从GitHub获取源代码：https://github.com/KimLionTan/LionReading
安装工具：
Xcode 15.2或更高版本：从Mac App Store下载安装
系统框架配置：
在项目设置的General中找到Frameworks, Libraries, and Embedded Content，添加EventKit.framework。
在Info.plist文件中添加以下隐私描述：Privacy-Calendars Usage Description，Privacy-Camera Usage Description，Privacy - Calendars Full Access Usage Description。
SQLite依赖：项目已配置SPM (Swift Package Manager)依赖，首次打开项目时会自动下载。如未自动下载，请手动导入sqlite.swift到Package Dependencies（可在Xcode依赖平台查找）
开发者账号准备：
如果没有Apple ID，请前往Apple ID创建页面注册一个 
启动Xcode后，点击顶部菜单栏的"Xcode" > "Settings..." > "Accounts" 
点击左下角的"+"按钮，选择"Apple ID"，输入你的Apple ID和密码进行登录 
登录后，Xcode会自动创建一个免费的Apple开发者账号，足够在模拟器上运行应用。（注意：本项目无需实体设备，所以不用注册付费会员！）
4. 运行应用
a.	双击解压后的文件夹中的.xcodeproj文件打开项目
b.	等待Xcode加载项目并下载所有依赖（首次打开可能需要几分钟）
c.	在Xcode顶部的设备选择器中选择"iPhone 16 Pro"或其他iOS 17.4兼容的模拟器
d.	点击左上角的三角形播放按钮编译并运行应用
e.	首次运行时，模拟器会请求日历权限，请点击"允许"以确保应用功能正常
