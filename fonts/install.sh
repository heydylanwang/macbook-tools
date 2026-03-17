#!/bin/bash
if fc-list | grep -q "Maple Mono NF CN"; then
    echo "✓ Maple Mono NF CN 字体已安装"
    exit 0
fi

echo "安装 Maple Mono NF CN 字体..."
brew tap homebrew/cask-fonts
brew install --cask font-maple

echo "✓ 字体安装完成"
echo "重启终端后生效"
