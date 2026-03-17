#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI 已安装: $(gh --version | head -1)"
    exit 0
fi

echo "📦 安装 GitHub CLI..."
brew install gh

echo "✅ GitHub CLI 安装完成！"
echo "💡 运行 'gh auth login' 登录 GitHub"
