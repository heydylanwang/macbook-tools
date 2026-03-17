#!/bin/bash
set -e

if command -v python3 &> /dev/null && command -v pip3 &> /dev/null; then
    echo "✅ Python3 已安装"
    exit 0
fi

echo "📦 安装 Python3..."
brew install python3

echo "✅ Python3 安装完成！"
