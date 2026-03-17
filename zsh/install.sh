#!/bin/bash
set -e

echo "🚀 开始安装 zsh 环境..."

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装 zsh（macOS 默认已安装）
if ! command -v zsh &> /dev/null; then
    echo "📦 安装 zsh..."
    brew install zsh
fi

# 设置 zsh 为默认 shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🔧 设置 zsh 为默认 shell..."
    chsh -s $(which zsh)
fi

# 安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 安装 Powerlevel10k 主题
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "📦 安装 Powerlevel10k 主题..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

# 安装插件
echo "📦 安装 zsh 插件..."

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# autojump
if ! command -v autojump &> /dev/null; then
    brew install autojump
fi

# 备份现有 .zshrc
if [ -f ~/.zshrc ]; then
    echo "💾 备份现有 .zshrc..."
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi

# 复制配置文件
echo "📝 配置 .zshrc..."
cp config/.zshrc ~/.zshrc

echo ""
echo "✅ zsh 环境安装完成！"
echo ""
echo "📌 下一步："
echo "1. 重启终端或运行: source ~/.zshrc"
echo "2. 运行 'p10k configure' 自定义主题"
echo ""
echo "💡 常用命令："
echo "  j <关键词>  - 智能目录跳转"
echo "  gst         - git status"
echo "  alias       - 查看所有别名"
