#!/bin/bash
# Claude-Mem 一键执行脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_PATH="${HOME}/.claude-mem/claude-mem.db"

show_menu() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         Claude-Mem 一键执行工具                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 数据库状态"
    SIZE_MB=$(du -m "$DB_PATH" 2>/dev/null | cut -f1)
    echo "   大小: ${SIZE_MB}MB"
    echo ""
    echo "🔍 选择操作:"
    echo ""
    echo "  [1] 📈 显示统计信息 (stats)"
    echo "  [2] 💾 创建备份 (backup)"
    echo "  [3] 🔍 检查健康状态 (check)"
    echo "  [4] 🧹 清理过期数据 (cleanup)"
    echo "  [5] 🔄 完整维护流程 (full)"
    echo "  [6] 📋 查看维护日志 (logs)"
    echo "  [7] 🚀 启动自动监控 (monitor-setup)"
    echo ""
    echo "  [0] 退出"
    echo ""
}

run_command() {
    case $1 in
        1) "$SCRIPT_DIR/maintenance.sh" stats ;;
        2) "$SCRIPT_DIR/maintenance.sh" backup ;;
        3) "$SCRIPT_DIR/maintenance.sh" check ;;
        4) "$SCRIPT_DIR/maintenance.sh" cleanup ;;
        5) "$SCRIPT_DIR/maintenance.sh" full ;;
        6) view_logs ;;
        7) setup_monitor ;;
        0) echo "再见!"; exit 0 ;;
        *) echo "❌ 无效选择" ;;
    esac
}

view_logs() {
    echo ""
    echo "📋 维护日志 (最近 20 条)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -20 ~/.claude-mem/maintenance.log 2>/dev/null || echo "日志文件不存在"
    echo ""
    echo "📋 告警日志 (最近 20 条)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -20 ~/.claude-mem/alerts.log 2>/dev/null || echo "告警日志为空"
}

setup_monitor() {
    echo ""
    echo "🚀 设置自动监控..."
    echo ""

    if [ ! -d ~/Library/LaunchAgents ]; then
        mkdir -p ~/Library/LaunchAgents
    fi

    cp "$SCRIPT_DIR/com.kryss.claude-mem.monitor.plist" ~/Library/LaunchAgents/ 2>/dev/null

    if launchctl list | grep -q "com.kryss.claude-mem.monitor"; then
        echo "⚠️  监控已在运行，卸载旧版本..."
        launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist 2>/dev/null || true
        sleep 1
    fi

    launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
    echo "✅ 自动监控已启动！"
    echo "   每天会自动检查数据库大小和发送告警"
    echo ""
    echo "验证状态:"
    launchctl list | grep claude-mem || echo "❌ 启动失败"
}

main() {
    if [ ! -f "$DB_PATH" ]; then
        echo "❌ 错误: 找不到数据库文件 $DB_PATH"
        echo "   请先安装 claude-mem"
        exit 1
    fi

    if [ -z "$1" ]; then
        # 交互模式
        while true; do
            show_menu
            read -p "请输入选项 [0-7]: " choice
            echo ""
            run_command "$choice"
            echo ""
            read -p "按回车继续..."
        done
    else
        # 命令行模式
        case "$1" in
            stats|backup|check|cleanup|full)
                "$SCRIPT_DIR/maintenance.sh" "$1" "${@:2}"
                ;;
            logs)
                view_logs
                ;;
            monitor-setup)
                setup_monitor
                ;;
            *)
                echo "用法: $0 {stats|backup|check|cleanup|full|logs|monitor-setup}"
                exit 1
                ;;
        esac
    fi
}

main "$@"
