#!/bin/bash
# 备份当前机器的 Claude Code CLAUDE.md 配置

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 备份 Claude Code 配置..."

if [ -f ~/.claude/CLAUDE.md ]; then
    cp ~/.claude/CLAUDE.md "$SCRIPT_DIR/CLAUDE.md.default"
    echo "  ✓ CLAUDE.md 已同步到 CLAUDE.md.default"
else
    echo "  ⚠️ ~/.claude/CLAUDE.md 不存在"
fi

if [ -f ~/.claude/settings.json ]; then
    cp ~/.claude/settings.json "$SCRIPT_DIR/settings.json.default"
    echo "  ✓ settings.json 已同步到 settings.json.default"
else
    echo "  ⚠️ ~/.claude/settings.json 不存在"
fi

echo "✅ 备份完成"
