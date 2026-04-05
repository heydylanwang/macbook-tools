#!/bin/bash
if ls ~/Library/Fonts/*Maple* &>/dev/null || ls /Library/Fonts/*Maple* &>/dev/null; then
    echo "✓ Maple Mono NF CN 字体已安装"
    exit 0
fi

echo "安装 Maple Mono NF CN 字体..."
brew install --cask font-maple-mono-nf-cn

echo "✓ 字体安装完成"
echo "重启终端后生效"
