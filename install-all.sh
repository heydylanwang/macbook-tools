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
if [ -f ~/.zshrc ] || [ -f ~/.claude/CLAUDE.md ] || [ -f ~/.config/ghostty/config ]; then
    echo "💾 备份现有配置到 $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    [ -f ~/.zshrc ] && cp ~/.zshrc "$BACKUP_DIR/"
    if [ -f ~/.claude/CLAUDE.md ]; then
        mkdir -p "$BACKUP_DIR/.claude"
        cp ~/.claude/CLAUDE.md "$BACKUP_DIR/.claude/"
    fi
    [ -d ~/.config/ghostty ] && cp -r ~/.config/ghostty "$BACKUP_DIR/"
    echo "✓ 备份完成"
fi

# 安装各组件
echo ""
echo "📦 [1/8] 安装终端基础工具..."
cd ghostty/tools && ./install-all.sh && cd ../..

echo ""
echo "📦 [2/8] 安装 zsh 环境..."
cd zsh && ./install.sh && cd ..

echo ""
echo "📦 [3/8] 安装 ghostty..."
cd ghostty && ./install.sh && cd ..

echo ""
echo "📦 [4/8] 安装 Zed 编辑器..."
cd zed && ./install.sh && cd ..

echo ""
echo "📦 [5/8] 安装 Rime 输入法..."
cd rime && ./install.sh && cd ..

echo ""
echo "📦 [6/8] 安装 Obsidian..."
cd obsidian && ./install.sh && cd ..

echo ""
echo "📦 [7/8] 安装 Claude Code..."
cd claude-code && ./install.sh && cd ..

echo ""
echo "📦 [8/8] 安装 claude-mem..."
cd claude-mem && ./install.sh && cd ..

# 设置 claude-mem 自动监控
echo ""
echo "🔧 配置 claude-mem 自动监控..."
if [ -d ~/Library/LaunchAgents ]; then
    mkdir -p ~/Library/LaunchAgents 2>/dev/null || true
    if sed "s|__HOME__|$HOME|g" claude-mem/com.local.claude-mem-sqlite-monitor.plist > ~/Library/LaunchAgents/com.local.claude-mem-sqlite-monitor.plist 2>/dev/null; then
        if launchctl list | grep -q "com.local.claude-mem-sqlite-monitor"; then
            launchctl unload ~/Library/LaunchAgents/com.local.claude-mem-sqlite-monitor.plist 2>/dev/null || true
        fi
        launchctl load ~/Library/LaunchAgents/com.local.claude-mem-sqlite-monitor.plist 2>/dev/null || true
        echo "✅ 自动监控已启用（每日自动检查数据库大小）"
    fi
fi

echo ""
echo "✅ 全量安装完成！"
echo ""
echo "📌 下一步："
echo "1. 重启终端"
echo "2. 运行 'claude auth login' 登录 Claude"
echo "3. 运行 'p10k configure' 配置 zsh 主题"
echo ""
echo "💾 原配置已备份到: $BACKUP_DIR"
echo ""
read -p "按回车键关闭..."
