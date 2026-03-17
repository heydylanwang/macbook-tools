#!/bin/bash
set -e

echo "🚀 开始安装终端基础工具..."
echo ""

TOOLS=(brew python git node gh vim fd autojump ffmpeg curl lazygit yazi)
TOTAL=${#TOOLS[@]}

for i in "${!TOOLS[@]}"; do
    tool="${TOOLS[$i]}"
    num=$((i + 1))
    echo ""
    echo "📦 [$num/$TOTAL] 安装 $tool..."
    cd "$tool" && ./install.sh && cd ..
done

echo ""
echo "✅ 终端基础工具安装完成！"
echo ""
echo "📌 已安装工具："
for tool in "${TOOLS[@]}"; do
    echo "  ✓ $tool"
done
