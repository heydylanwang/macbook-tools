#!/bin/bash
set -e

if command -v brew &> /dev/null; then
    echo "✅ Homebrew 已安装"
    exit 0
fi

echo "📦 安装 Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "✅ Homebrew 安装完成！"
