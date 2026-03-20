#!/bin/bash
# Claude-Mem 自动清理守护脚本
# 清理卡住的 pending_messages 和孤立数据

DB_PATH="${HOME}/.claude-mem/claude-mem.db"
LOG_FILE="${HOME}/.claude-mem/auto-cleanup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

cleanup_stale_pending_messages() {
    # 清理满足以下条件的消息：
    # 1. 状态是 'pending' 或 'processing'
    # 2. 最后更新超过 24 小时
    # 3. 重试次数 > 3 次（表示已经尝试过但失败）

    local CUTOFF_TIMESTAMP=$(($(date +%s) - 86400))  # 24 小时前

    log "开始清理卡住的 pending_messages..."

    # 统计待清理的消息
    local STALE_COUNT=$(sqlite3 "$DB_PATH" <<SQL
SELECT COUNT(*) FROM pending_messages
WHERE (status = 'pending' OR status = 'processing')
  AND (started_processing_at_epoch IS NOT NULL
       AND started_processing_at_epoch < $CUTOFF_TIMESTAMP)
  AND retry_count >= 3;
SQL
)

    if [ "$STALE_COUNT" -gt 0 ]; then
        log "⚠️  发现 $STALE_COUNT 条卡住的消息（>24小时未更新，重试≥3次）"

        # 备份数据
        cp "$DB_PATH" "$DB_PATH.backup_before_stale_cleanup_$(date +%Y%m%d_%H%M%S)"

        # 清理操作
        sqlite3 "$DB_PATH" <<SQL
BEGIN TRANSACTION;

DELETE FROM pending_messages
WHERE (status = 'pending' OR status = 'processing')
  AND (started_processing_at_epoch IS NOT NULL
       AND started_processing_at_epoch < $CUTOFF_TIMESTAMP)
  AND retry_count >= 3;

COMMIT;
SQL

        log "✅ 清理完成，删除了 $STALE_COUNT 条卡住的消息"
    else
        log "✅ 没有卡住的消息需要清理"
    fi
}

cleanup_orphaned_sessions() {
    # 清理没有对应会话的孤立 pending_messages

    log "清理孤立消息（对应会话已删除）..."

    local ORPHANED_COUNT=$(sqlite3 "$DB_PATH" <<SQL
SELECT COUNT(*) FROM pending_messages pm
WHERE NOT EXISTS (
    SELECT 1 FROM sdk_sessions ss
    WHERE ss.id = pm.session_db_id
);
SQL
)

    if [ "$ORPHANED_COUNT" -gt 0 ]; then
        log "⚠️  发现 $ORPHANED_COUNT 条孤立消息（会话已删除）"

        # 备份
        cp "$DB_PATH" "$DB_PATH.backup_before_orphan_cleanup_$(date +%Y%m%d_%H%M%S)"

        # 清理
        sqlite3 "$DB_PATH" <<SQL
BEGIN TRANSACTION;

DELETE FROM pending_messages pm
WHERE NOT EXISTS (
    SELECT 1 FROM sdk_sessions ss
    WHERE ss.id = pm.session_db_id
);

COMMIT;
SQL

        log "✅ 清理完成，删除了 $ORPHANED_COUNT 条孤立消息"
    else
        log "✅ 没有孤立消息"
    fi
}

cleanup_failed_messages() {
    # 清理已标记为失败且 7 天未更新的消息

    log "清理已失败的消息（>7天）..."

    local CUTOFF_TIMESTAMP=$(($(date +%s) - 604800))  # 7 天前

    local FAILED_COUNT=$(sqlite3 "$DB_PATH" <<SQL
SELECT COUNT(*) FROM pending_messages
WHERE status = 'failed'
  AND (failed_at_epoch IS NOT NULL
       AND failed_at_epoch < $CUTOFF_TIMESTAMP);
SQL
)

    if [ "$FAILED_COUNT" -gt 0 ]; then
        log "⚠️  发现 $FAILED_COUNT 条已失败消息（>7天）"

        # 备份
        cp "$DB_PATH" "$DB_PATH.backup_before_failed_cleanup_$(date +%Y%m%d_%H%M%S)"

        # 清理
        sqlite3 "$DB_PATH" <<SQL
BEGIN TRANSACTION;

DELETE FROM pending_messages
WHERE status = 'failed'
  AND (failed_at_epoch IS NOT NULL
       AND failed_at_epoch < $CUTOFF_TIMESTAMP);

COMMIT;
SQL

        log "✅ 清理完成，删除了 $FAILED_COUNT 条已失败消息"
    else
        log "✅ 没有过期失败消息"
    fi
}

show_summary() {
    echo ""
    log "清理完成，汇总统计："

    sqlite3 "$DB_PATH" <<SQL
SELECT
  'pending_messages 统计' as category,
  COUNT(*) as total,
  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count,
  SUM(CASE WHEN status = 'processing' THEN 1 ELSE 0 END) as processing_count,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_count,
  SUM(CASE WHEN status = 'processed' THEN 1 ELSE 0 END) as processed_count
FROM pending_messages;
SQL

    local SIZE_MB=$(du -m "$DB_PATH" 2>/dev/null | cut -f1)
    log "数据库大小: ${SIZE_MB}MB"
}

cleanup_backup_files() {
    # 只保留最近 30 个清理备份
    log "整理备份文件..."

    BACKUP_COUNT=$(ls -1 "$DB_PATH".backup_before_*_cleanup_* 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 30 ]; then
        log "⚠️  清理备份超过 30 个，删除旧备份..."
        ls -t "$DB_PATH".backup_before_*_cleanup_* 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null
        log "✅ 清理备份文件完成"
    fi
}

main() {
    if [ ! -f "$DB_PATH" ]; then
        log "ERROR: 数据库文件不存在: $DB_PATH"
        return 1
    fi

    log "=== 自动清理开始 ==="

    cleanup_stale_pending_messages
    cleanup_orphaned_sessions
    cleanup_failed_messages
    cleanup_backup_files

    show_summary

    log "=== 自动清理结束 ==="
    echo ""
}

main "$@"
