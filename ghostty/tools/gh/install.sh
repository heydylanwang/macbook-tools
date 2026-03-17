#!/bin/bash
set -e

if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI 已安装"
    exit 0
fi

echo "📦 安装 GitHub CLI..."
brew install gh

echo "✅ GitHub CLI 安装完成！"
echo "💡 运行 'gh auth login' 登录 GitHub"
