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
echo "✅ Claude Code 安装完成！"
echo "📌 运行 'claude auth login' 登录后即可使用"
