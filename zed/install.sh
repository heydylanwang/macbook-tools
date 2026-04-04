#!/bin/bash
set -e

echo "🚀 开始安装 Zed 编辑器..."

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装 Zed
if ! command -v zed &> /dev/null; then
    echo "📦 安装 Zed..."
    brew install --cask zed
else
    echo "✅ Zed 已安装"
fi

# 恢复配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZED_CONFIG_DIR="$HOME/.config/zed"

if [ -f "$SCRIPT_DIR/config/settings.json" ]; then
    mkdir -p "$ZED_CONFIG_DIR"
    if [ -f "$ZED_CONFIG_DIR/settings.json" ]; then
        cp "$ZED_CONFIG_DIR/settings.json" "$ZED_CONFIG_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    cp "$SCRIPT_DIR/config/settings.json" "$ZED_CONFIG_DIR/settings.json"
    echo "✓ 配置已恢复"
fi

echo ""
echo "✅ Zed 安装完成！"
echo ""
echo "📌 用法："
echo "  zed .          - 打开当前目录"
echo "  zed file.txt   - 编辑文件"
echo "  Cmd + Shift + P - 命令面板"
