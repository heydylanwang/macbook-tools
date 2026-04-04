#!/bin/bash
set -e

echo "🚀 开始安装 Obsidian..."

VAULT_DIR="$HOME/projects/Dylan"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装 Obsidian
if [ ! -d "/Applications/Obsidian.app" ]; then
    echo "📦 安装 Obsidian..."
    brew install --cask obsidian
else
    echo "✅ Obsidian 已安装"
fi

# 创建 vault 目录
mkdir -p "$VAULT_DIR"

# 恢复 .obsidian 配置
echo "📝 恢复 Obsidian 配置..."
mkdir -p "$VAULT_DIR/.obsidian"
cp -n "$SCRIPT_DIR/config/.obsidian/"* "$VAULT_DIR/.obsidian/" 2>/dev/null || true

# 恢复 snippets
mkdir -p "$VAULT_DIR/.obsidian/snippets"
cp -n "$SCRIPT_DIR/config/snippets/"*.css "$VAULT_DIR/.obsidian/snippets/" 2>/dev/null || true
echo "✓ 配置恢复完成"

echo ""
echo "✅ Obsidian 安装完成！"
echo ""
echo "📌 下一步："
echo "1. 打开 Obsidian，选择「打开文件夹作为仓库」→ $VAULT_DIR"
echo "2. CSS snippets 已就绪，在设置 → 外观 → CSS 代码片段中启用"
