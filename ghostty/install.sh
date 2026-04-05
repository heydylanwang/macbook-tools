#!/bin/bash
set -e

echo "🚀 开始安装 ghostty..."

# 先安装终端基础工具
if [ -f tools/install-all.sh ]; then
    echo "📦 安装终端基础工具..."
    cd tools && ./install-all.sh && cd ..
    echo ""
fi

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装 ghostty
if ! command -v ghostty &> /dev/null; then
    echo "📦 安装 ghostty..."
    brew install --cask ghostty
else
    echo "✅ ghostty 已安装"
fi

# 创建配置目录
mkdir -p ~/.config/ghostty

# 备份现有配置
if [ -f ~/.config/ghostty/config ]; then
    echo "💾 备份现有配置..."
    cp ~/.config/ghostty/config ~/.config/ghostty/config.backup.$(date +%Y%m%d_%H%M%S)
fi

# 复制配置文件
echo "📝 配置 ghostty..."
cp config/ghostty-config ~/.config/ghostty/config

# 安装 yazi
if ! command -v yazi &> /dev/null; then
    echo "📦 安装 yazi..."
    brew install yazi
fi

# 安装 lazygit
if ! command -v lazygit &> /dev/null; then
    echo "📦 安装 lazygit..."
    brew install lazygit
fi

# 安装 zoxide（yazi 的 Z 键依赖）
if ! command -v zoxide &> /dev/null; then
    echo "📦 安装 zoxide..."
    brew install zoxide
fi

# 配置 yazi shell wrapper
if ! grep -q "function y()" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Yazi - 文件管理器 shell wrapper" >> ~/.zshrc
    echo 'function y() {' >> ~/.zshrc
    echo '	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd' >> ~/.zshrc
    echo '	command yazi "$@" --cwd-file="$tmp"' >> ~/.zshrc
    echo '	IFS= read -r -d "" cwd < "$tmp"' >> ~/.zshrc
    echo '	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"' >> ~/.zshrc
    echo '	rm -f -- "$tmp"' >> ~/.zshrc
    echo '}' >> ~/.zshrc
fi

# 配置 zoxide
if ! grep -q "zoxide init" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Zoxide - 智能目录跳转" >> ~/.zshrc
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
fi

echo ""
echo "✅ ghostty 安装完成！"
echo ""
echo "📌 快捷键："
echo "  Ctrl + \`        - 快速终端（全局）"
echo "  Cmd + T         - 新建标签页"
echo "  Cmd + D         - 右侧分屏"
echo "  Cmd + Shift + D - 下方分屏"
echo ""
echo "💡 集成工具："
echo "  y        - 启动 yazi 文件管理器"
echo "  lazygit  - 启动 Git 管理工具"
echo ""
echo "🔧 配置文件: ~/.config/ghostty/config"
