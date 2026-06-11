#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 配置 Git..."

# 复制全局 gitignore
cp "$SCRIPT_DIR/gitignore_global" "$HOME/.gitignore_global"

# 设置基础配置
git config --global core.excludesfile "$HOME/.gitignore_global"

# 用户信息（装机时需手动设置）
if [ -z "$(git config --global user.name)" ]; then
    echo "⚠️  请手动设置 Git 用户信息："
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your@email.com\""
fi

echo "✅ Git 配置完成"
