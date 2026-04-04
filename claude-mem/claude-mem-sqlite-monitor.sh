#!/bin/bash
# claude-mem 监控和告警脚本（可通过 launchd/cron 定期运行）

DB_PATH="${HOME}/.claude-mem/claude-mem.db"
ALERT_LOG="${HOME}/.claude-mem/alerts.log"

alert() {
    local level=$1
    local message=$2
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$ALERT_LOG"

    # 可选：发送系统通知（macOS）
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"Claude-Mem Alert: $level\""
    fi
}

main() {
    if [ ! -f "$DB_PATH" ]; then
        alert "ERROR" "数据库不存在: $DB_PATH"
        return 1
    fi

    # 检查数据库大小
    SIZE_MB=$(du -m "$DB_PATH" 2>/dev/null | cut -f1)

    if [ "$SIZE_MB" -ge 1024 ]; then
        alert "CRITICAL" "数据库大小 ${SIZE_MB}MB 超过 1GB，需立即处理"
        return 2
    elif [ "$SIZE_MB" -ge 500 ]; then
        alert "WARNING" "数据库大小 ${SIZE_MB}MB 超过 500MB，建议清理"
        return 1
    elif [ "$SIZE_MB" -ge 200 ]; then
        alert "INFO" "数据库大小 ${SIZE_MB}MB，接近 200MB 阈值"
        return 0
    fi

    return 0
}

main "$@"
