#!/bin/bash
set -e

echo "🚀 开始安装 Rime 输入法..."

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ 未检测到 Homebrew，请先安装：https://brew.sh"
    exit 1
fi

# 安装鼠须管
if [ ! -d "/Library/Input Methods/Squirrel.app" ]; then
    echo "📦 安装鼠须管 (Squirrel)..."
    brew install --cask squirrel
else
    echo "✅ 鼠须管已安装"
fi

RIME_DIR="$HOME/Library/Rime"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 备份现有配置
if [ -d "$RIME_DIR" ] && [ "$(ls -A "$RIME_DIR" 2>/dev/null)" ]; then
    BACKUP_DIR="$RIME_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    echo "💾 备份现有配置到 $BACKUP_DIR..."
    cp -r "$RIME_DIR" "$BACKUP_DIR"
fi

# 复制配置（保留 build、userdb、user.yaml）
echo "📝 恢复 Rime 配置..."
mkdir -p "$RIME_DIR"
rsync -av --exclude='.DS_Store' "$SCRIPT_DIR/config/" "$RIME_DIR/"
echo "✓ 配置恢复完成"

# 触发重新部署
echo "🔧 触发 Rime 重新部署..."
if [ -d "/Library/Input Methods/Squirrel.app" ]; then
    "/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload 2>/dev/null || true
fi

echo ""
echo "✅ Rime 输入法安装完成！"
echo ""
echo "📌 下一步："
echo "1. 系统设置 → 键盘 → 输入法 → 添加「鼠须管」"
echo "2. 如需调整，编辑 ~/Library/Rime/ 下的配置文件"
echo "3. 修改后按 Control+Option+\` 重新部署"
