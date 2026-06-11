#!/bin/bash
set -e

echo "🍎 配置 macOS 系统偏好..."

# 关闭修改确认提示
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# ========== Dock ==========
# 不自动隐藏 Dock
defaults write com.apple.dock autohide -bool false
# 不显示最近使用的应用
defaults write com.apple.dock show-recents -bool false

# ========== Finder ==========
# 显示所有文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 显示路径栏
defaults write com.apple.finder ShowPathbar -bool true
# 显示状态栏
defaults write com.apple.finder ShowStatusBar -bool true
# 搜索时默认搜索当前文件夹
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 禁止在网络驱动器上创建 .DS_Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# ========== 触控板 ==========
# 轻触点击
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ========== 键盘 ==========
# 禁用自动大写
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# 禁用自动句号
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# 禁用智能引号
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# 禁用智能破折号
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# 禁用拼写自动纠正
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ========== 外观 ==========
# 深色模式（自动切换）
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# ========== 截图 ==========
# 截图保存到桌面
defaults write com.apple.screencapture location -string "$HOME/Desktop"
# 截图格式 PNG
defaults write com.apple.screencapture type -string "png"
# 禁用截图阴影
defaults write com.apple.screencapture disable-shadow -bool true

# 重启相关服务
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "✅ macOS 系统偏好配置完成"
echo "📌 部分设置需要重新登录后生效"
