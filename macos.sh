#!/bin/bash

# ==============================================================================
# 🍎 macOS 系统偏好设置
# ==============================================================================
# 一组合理的 macOS 默认配置。
# 参考：https://mths.be/macos

# 关闭所有已打开的"系统设置"窗口，防止它们覆盖我们即将更改的设置
osascript -e 'tell application "System Preferences" to quit'

# 预先请求管理员密码
sudo -v

# 保持 sudo 权限：每隔 60 秒更新一次 sudo 时间戳，直到脚本执行完毕
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "正在配置 macOS..."

###############################################################################
# 通用界面与用户体验                                                          #
###############################################################################

# 设置极快的键盘重复速率
# 默认值：KeyRepeat = 2 (30ms)，InitialKeyRepeat = 15 (225ms)
# KeyRepeat：重复速率（数字越小越快，1 是最快）
defaults write NSGlobalDomain KeyRepeat -int 1
# InitialKeyRepeat：首次重复前的延迟（单位：毫秒，约 150ms）
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# 禁用按键长按功能，改为重复输入该按键（对 Vim 用户很有用）
# 默认值：true（启用长按显示特殊字符选择菜单）
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# 睡眠或屏幕保护开始后立即要求输入密码
# 默认值：askForPassword = 0 (false)，askForPasswordDelay = 300 (5分钟)
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# 默认展开保存对话框
# 默认值：false（保存对话框以紧凑模式显示）
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# 默认展开打印对话框
# 默认值：false（打印对话框以紧凑模式显示）
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# 打印任务完成后自动退出打印机应用
# 默认值：false（打印完成后保持打印机应用打开）
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

###############################################################################
# 触控板、鼠标、键盘、蓝牙配件及输入法                                        #
###############################################################################

# 触控板：为当前用户和登录屏幕启用轻点点击
# 默认值：false（0，需要用力点击才能点击）
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Finder（访达）                                                              #
###############################################################################

# 显示所有文件扩展名
# 默认值：false（隐藏已知文件类型的扩展名）
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 显示状态栏
# 默认值：false（不显示底部状态栏）
defaults write com.apple.finder ShowStatusBar -bool true

# 显示路径栏
# 默认值：false（不显示底部路径栏）
defaults write com.apple.finder ShowPathbar -bool true

# 按名称排序时将文件夹保持在顶部
# 默认值：false（文件夹与文件混合排序）
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# 搜索时默认搜索当前文件夹
# 默认值：SCev (搜索此 Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# 避免在网络卷或 USB 存储设备上创建 .DS_Store 文件
# 默认值：false（会在网络/USB 卷上创建 .DS_Store 文件）
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# 更改文件扩展名时禁用警告提示
# 默认值：true（更改扩展名时显示警告）
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

###############################################################################
# 程序坞（Dock）、仪表盘（Dashboard）和触发角                                  #
###############################################################################

# 自动隐藏和显示程序坞
# 默认值：false（Dock 始终可见）
defaults write com.apple.dock autohide -bool true

# 不在程序坞中显示最近使用的应用
# 默认值：true（显示最近使用的应用）
defaults write com.apple.dock show-recents -bool false

# 隐藏应用的程序坞图标显示为半透明
# 默认值：false（隐藏应用的图标不透明）
defaults write com.apple.dock showhidden -bool true

###############################################################################
# Safari 浏览器及 WebKit                                                      #
###############################################################################

# 在 Safari 中启用"开发"菜单和 Web 检查器
# 默认值：false（开发菜单和 Web 检查器未启用）
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# 在网页视图中添加右键菜单项以显示 Web 检查器
# 默认值：false（右键菜单中不显示检查元素选项）
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# 活动监视器                                                                #
###############################################################################

# 启动活动监视器时显示主窗口
# 默认值：false（启动时可能显示的是上次关闭时的窗口）
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# 在活动监视器 Dock 图标中显示 CPU 使用情况
# 默认值：0（显示应用图标）
defaults write com.apple.ActivityMonitor IconType -int 5

# 显示所有进程（而不仅是我的进程）
# 默认值：100（"我的进程"视图）
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# 按 CPU 使用率排序活动监视器结果
# 默认值：Name（按名称排序），SortDirection = 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Mac App Store                                                             #
###############################################################################

# 启用自动检查更新
# 默认值：true（已启用自动检查更新）
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# 每天检查软件更新（而非每周一次）
# 默认值：7（每周检查一次）
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# 在后台自动下载可用更新
# 默认值：0（不自动下载）
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# 安装系统数据文件和安全更新
# 默认值：0（不自动安装关键更新）
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# 重启受影响的应用                                                          #
###############################################################################

for app in "Activity Monitor" \
	"Dock" \
	"Finder" \
	"Safari" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null || true
done

echo "完成。注意：部分更改需要注销或重启后才能生效。"
