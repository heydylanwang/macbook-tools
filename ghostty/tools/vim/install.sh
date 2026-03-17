#!/bin/bash
set -e

if command -v vim &> /dev/null; then
    echo "✅ Vim 已安装"
    exit 0
fi

echo "📦 安装 Vim..."
brew install vim

echo "✅ Vim 安装完成！"
