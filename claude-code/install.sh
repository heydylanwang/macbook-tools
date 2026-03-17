#!/bin/bash
set -e

echo "🚀 开始安装 Claude Code..."

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装 Claude Code
if ! command -v claude &> /dev/null; then
    echo "📦 安装 Claude Code..."
    brew install claude
else
    echo "✅ Claude Code 已安装"
fi

# 创建配置目录
mkdir -p ~/.claude/memory

# 备份现有配置
if [ -f ~/.claude/CLAUDE.md ]; then
    echo "💾 备份现有配置..."
    cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
fi

# 复制全局规则
echo "📝 配置全局规则..."
cp config/CLAUDE.md ~/.claude/CLAUDE.md

# 复制 settings.json
if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json ~/.claude/settings.json.backup.$(date +%Y%m%d_%H%M%S)
fi
cp config/settings.json ~/.claude/settings.json

# 复制 memory 模板
cp config/memory/MEMORY.md ~/.claude/memory/MEMORY.md

# 登录提示
echo ""
echo "✅ Claude Code 安装完成！"
echo ""
echo "📌 下一步："
echo "1. 运行 'claude auth login' 登录账号"
echo "2. 运行 'claude chat' 开始对话"
echo ""
echo "📚 配置文件位置："
echo "  - 全局规则: ~/.claude/CLAUDE.md"
echo "  - 权限配置: ~/.claude/settings.json"
echo "  - 记忆目录: ~/.claude/memory/"
