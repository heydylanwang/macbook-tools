#!/bin/bash
# claude-mem 数据库维护脚本

DB_PATH="${HOME}/.claude-mem/claude-mem.db"
BACKUP_DIR="${HOME}/.claude-mem/backups"
LOG_FILE="${HOME}/.claude-mem/maintenance.log"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 1. 备份数据库
backup_database() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/claude-mem.db.backup_$TIMESTAMP"

    if [ ! -f "$DB_PATH" ]; then
        log "ERROR: 数据库文件不存在: $DB_PATH"
        return 1
    fi

    cp "$DB_PATH" "$BACKUP_FILE"
    log "✅ 备份完成: $BACKUP_FILE (大小: $(du -h "$BACKUP_FILE" | cut -f1))"

    # 只保留最近 10 个备份
    ls -t "$BACKUP_DIR"/claude-mem.db.backup_* 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
}

# 2. 检查数据库大小
check_size() {
    SIZE_MB=$(du -m "$DB_PATH" 2>/dev/null | cut -f1)

    if [ "$SIZE_MB" -ge 1024 ]; then
        log "🚨 危险: 数据库达到 ${SIZE_MB}MB (>1GB阈值)"
        return 2
    elif [ "$SIZE_MB" -ge 500 ]; then
        log "⚠️  告警: 数据库 ${SIZE_MB}MB (>500MB阈值) - 建议清理"
        return 1
    elif [ "$SIZE_MB" -ge 200 ]; then
        log "⚠️  关注: 数据库 ${SIZE_MB}MB (>200MB阈值) - 可考虑清理"
        return 0
    fi

    log "✅ 数据库健康: ${SIZE_MB}MB"
    return 0
}

# 3. 清理过期数据（需要备份后调用）
cleanup_old_data() {
    local keep_count=${1:-5000}

    log "开始清理过期数据... (保留最近 $keep_count 条 observations)"

    # 检查是否有备份
    if [ ! "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        log "ERROR: 没有备份文件，拒绝执行清理"
        return 1
    fi

    # 清理多余的 observations
    sqlite3 "$DB_PATH" <<SQL
DELETE FROM observations
WHERE id NOT IN (
  SELECT id FROM observations
  ORDER BY created_at DESC
  LIMIT $keep_count
);
SQL

    # 清理孤立的 pending_messages
    sqlite3 "$DB_PATH" <<SQL
DELETE FROM pending_messages
WHERE id NOT IN (
  SELECT id FROM pending_messages
  WHERE created_at > datetime('now', '-7 days')
  ORDER BY created_at DESC
  LIMIT 200
);
SQL

    log "✅ 清理完成"
}

# 4. 显示统计信息
show_stats() {
    echo "📊 claude-mem 数据库统计"
    echo "========================"

    sqlite3 "$DB_PATH" <<SQL
.mode column
.headers on
SELECT
  'observations' as "表名", COUNT(*) as "记录数" FROM observations
UNION ALL
SELECT 'pending_messages', COUNT(*) FROM pending_messages
UNION ALL
SELECT 'user_prompts', COUNT(*) FROM user_prompts
UNION ALL
SELECT 'sdk_sessions', COUNT(*) FROM sdk_sessions
UNION ALL
SELECT 'session_summaries', COUNT(*) FROM session_summaries;
SQL

    SIZE_MB=$(du -m "$DB_PATH" 2>/dev/null | cut -f1)
    echo "📁 数据库大小: ${SIZE_MB}MB"
    echo "📅 最后修改: $(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$DB_PATH")"
}

# 主程序
main() {
    local action=${1:-status}

    case "$action" in
        backup)
            backup_database
            ;;
        check)
            check_size
            ;;
        cleanup)
            backup_database && cleanup_old_data "${2:-5000}"
            ;;
        stats)
            show_stats
            ;;
        full)
            # 完整维护：备份 → 检查 → 显示
            backup_database
            check_size
            show_stats
            ;;
        *)
            echo "用法: $0 {backup|check|cleanup|stats|full}"
            echo ""
            echo "命令说明:"
            echo "  backup   - 创建数据库备份"
            echo "  check    - 检查数据库大小并告警"
            echo "  cleanup  - 备份后清理过期数据 (需手动确认)"
            echo "  stats    - 显示数据库统计信息"
            echo "  full     - 执行完整维护 (备份→检查→统计)"
            exit 1
            ;;
    esac
}

main "$@"
