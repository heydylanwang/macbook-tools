#!/bin/bash
set -e

echo "🚀 开始安装 claude-mem..."

# 检查 bun
if ! command -v bun &> /dev/null; then
    echo "📦 安装 bun..."
    curl -fsSL https://bun.sh/install | bash
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
fi

# 检查 Claude Code
if ! command -v claude &> /dev/null; then
    echo "❌ 请先安装 Claude Code"
    exit 1
fi

# 检查 claude-mem 是否已安装
if [ -d ~/.claude/plugins/cache/thedotmack/claude-mem ]; then
    echo "✅ claude-mem 插件已安装"
else
    echo "📦 安装 claude-mem 插件..."
    claude plugin marketplace add thedotmack/claude-mem
    claude plugin install claude-mem
fi

# 创建 cm-worker 快捷脚本
echo "📝 创建快捷命令..."
mkdir -p ~/.local/bin

cat > ~/.local/bin/cm-worker << 'EOF'
#!/bin/bash
PLUGIN_DIR=$(ls -d ~/.claude/plugins/cache/thedotmack/claude-mem/*/ 2>/dev/null | sort -V | tail -1)
exec bun "${PLUGIN_DIR}scripts/worker-service.cjs" "$@"
EOF

chmod +x ~/.local/bin/cm-worker

# 设置脚本权限
chmod +x "$(dirname "$0")"/{maintenance,monitor,run}.sh

# 添加别名到 .zshrc
if ! grep -q "alias cm-worker=" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Claude-Mem 快捷别名" >> ~/.zshrc
    echo "alias cm-worker='~/.local/bin/cm-worker'" >> ~/.zshrc
    echo "alias cm-health='cm-worker health'" >> ~/.zshrc
    echo "alias cm-status='cm-worker status'" >> ~/.zshrc
    echo "alias cm-stats='cm-worker stats'" >> ~/.zshrc
    echo "alias cm-queue='cm-worker queue'" >> ~/.zshrc
    echo "alias cm-viewer='cm-worker viewer'" >> ~/.zshrc
    echo "alias cm-start='cm-worker start'" >> ~/.zshrc
    echo "alias cm-stop='cm-worker stop'" >> ~/.zshrc
    echo "alias cm-restart='cm-worker restart'" >> ~/.zshrc
    echo "alias cm-logs='cm-worker logs'" >> ~/.zshrc
    echo "alias cm-maint='~/projects/macbook-tools/claude-mem/maintenance.sh'" >> ~/.zshrc
    echo "alias cm-run='~/projects/macbook-tools/claude-mem/run.sh'" >> ~/.zshrc
fi

# 启动服务
echo "🚀 启动 claude-mem 服务..."
~/.local/bin/cm-worker start

echo ""
echo "✅ claude-mem 安装完成！"
echo ""
echo "📌 常用命令："
echo "  cm-status   - 查看服务状态"
echo "  cm-stats    - 查看统计信息"
echo "  cm-viewer   - 打开可视化界面"
echo "  cm-logs     - 查看日志"
echo ""
echo "💡 重启终端后生效，或运行: source ~/.zshrc"
