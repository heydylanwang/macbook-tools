#!/bin/bash
set -e

echo "🚀 开始安装 Claude Code..."

# 检查是否已安装
if command -v claude &> /dev/null; then
    echo "✅ Claude Code 已安装: $(claude --version 2>/dev/null || echo 'unknown')"
else
    echo "📦 安装 Claude Code..."
    brew tap anthropics/claude
    brew install claude
    echo "✓ 安装完成"
fi

echo ""
read -p "是否使用本机备份配置覆盖？(y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "📝 应用备份配置..."

    # 备份现有配置
    if [ -f ~/.claude/CLAUDE.md ]; then
        cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
    fi

    # 复制全局配置
    mkdir -p ~/.claude
    cp config/CLAUDE.md ~/.claude/CLAUDE.md
    [ -f config/settings.json ] && cp config/settings.json ~/.claude/settings.json
    echo "  ✓ 全局配置已覆盖"

    # 恢复 memory 目录
    if [ -d config/memory ]; then
        echo "📂 恢复 memory 目录..."
        for backup_project in config/memory/*; do
            if [ -d "$backup_project" ]; then
                project_name=$(basename "$backup_project")
                target_dir=~/.claude/projects/"$project_name"/memory
                mkdir -p "$target_dir"
                cp -r "$backup_project"/* "$target_dir/"
                echo "  ✓ 恢复 $project_name/memory"
            fi
        done
    fi

    echo "✅ 配置恢复完成"
fi
