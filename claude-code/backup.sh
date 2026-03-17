#!/bin/bash
# 备份当前机器的 Claude Code 配置

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config"
mkdir -p "$BACKUP_DIR/memory"

echo "📦 备份 Claude Code 配置..."

# 备份全局配置
[ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md "$BACKUP_DIR/"
[ -f ~/.claude/settings.json ] && cp ~/.claude/settings.json "$BACKUP_DIR/"

# 备份 memory 目录（所有项目）
if [ -d ~/.claude/projects ]; then
    for project_dir in ~/.claude/projects/*/memory; do
        if [ -d "$project_dir" ]; then
            project_name=$(basename $(dirname "$project_dir"))
            echo "  ✓ 备份 $project_name/memory"
            mkdir -p "$BACKUP_DIR/memory/$project_name"
            cp -r "$project_dir"/* "$BACKUP_DIR/memory/$project_name/" 2>/dev/null || true
        fi
    done
fi

echo "✅ 备份完成: $BACKUP_DIR"
