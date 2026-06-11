#!/bin/bash
set -e

echo "🚀 开始全量安装开发环境..."
echo "⏳ 正在初始化，请稍候..."
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 工作目录: $SCRIPT_DIR"
echo ""

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 备份现有配置（排除大文件）
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d)"
if [ -f ~/.zshrc ] || [ -f ~/.config/ghostty/config ]; then
    echo "💾 备份现有配置到 $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    [ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
    [ -d ~/.config/ghostty ] && cp -r ~/.config/ghostty "$BACKUP_DIR/"
    echo "✓ 备份完成"
fi

# 从 Brewfile 安装所有 brew 包
echo ""
echo "📦 [0/10] 从 Brewfile 安装所有包..."
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    brew bundle install --file="$SCRIPT_DIR/Brewfile"
    echo "✓ Brewfile 安装完成"
else
    echo "⚠️  未找到 Brewfile，跳过"
fi

# 安装各组件
echo ""
echo "📦 [1/10] 安装终端基础工具..."
cd ghostty/tools && ./install-all.sh && cd ../..

echo ""
echo "📦 [2/10] 安装字体..."
cd fonts && ./install.sh && cd ..

echo ""
echo "📦 [3/10] 安装 zsh 环境..."
cd zsh && ./install.sh && cd ..

echo ""
echo "📦 [4/10] 安装 ghostty..."
cd ghostty && ./install.sh && cd ..

echo ""
echo "📦 [5/10] 安装 Zed 编辑器..."
cd zed && ./install.sh && cd ..

echo ""
echo "📦 [6/10] 安装 Rime 输入法..."
cd rime && ./install.sh && cd ..

echo ""
echo "📦 [7/10] 安装 Obsidian..."
cd obsidian && ./install.sh && cd ..

echo ""
echo "📦 [8/10] 安装 Claude Code..."
cd claude-code && ./install.sh && cd ..

echo ""
echo "📦 [9/10] 配置 Git..."
cd git && ./install.sh && cd ..

echo ""
echo "📦 [10/10] 配置 macOS 系统偏好..."
cd macos && ./install.sh && cd ..

echo ""
echo "✅ 全量安装完成！"
echo ""
echo "📌 下一步："
echo "1. 重启终端"
echo "2. 挂载 vault 恢复 SSH 密钥: vault"
echo "3. 设置 Git 用户: git config --global user.name/email"
echo "4. 运行 'claude auth login' 登录 Claude"
echo "5. 运行 'p10k configure' 配置 zsh 主题"
echo ""
echo "💾 原配置已备份到: $BACKUP_DIR"
echo ""
read -p "按回车键关闭..."
