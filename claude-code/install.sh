#!/bin/bash
set -e

echo "🚀 开始安装 Claude Code..."

# 检查是否已安装
if command -v claude &> /dev/null; then
    echo "✅ Claude Code 已安装: $(claude --version 2>/dev/null || echo 'unknown')"
else
    echo "📦 安装 Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    echo "✓ 安装完成"
fi

echo ""
read -p "是否使用本机备份配置覆盖 CLAUDE.md？(y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ~/.claude
    cp CLAUDE.md.default ~/.claude/CLAUDE.md
    echo "  ✓ CLAUDE.md 已覆盖"
    cp settings.json.default ~/.claude/settings.json
    echo "  ✓ settings.json 已覆盖（含 MCP/插件配置）"
fi

echo ""
echo "✅ Claude Code 安装完成！"
echo "📌 运行 'claude auth login' 登录后即可使用"
