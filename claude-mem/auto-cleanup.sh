#!/bin/bash
# Claude-Mem 自动清理守护脚本（每周一次）
# 清理孤立消息和失败消息（>30天）

DB_PATH="${HOME}/.claude-mem/claude-mem.db"
LOG_FILE="${HOME}/.claude-mem/auto-cleanup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# ⚠️  DISABLED: 不清理 pending/processing 消息
#
# Claude-Mem 有内置的自动恢复机制：
# - Worker 启动时，resetStaleProcessingMessages() 自动将 processing 消息重置为 pending
# - pending 消息随时可能被继续处理
# - 我们无法确定一个消息是否真的失效，所以不能安全删除
#
# 详见 PENDING_MESSAGES.md 的"安全性"章节

cleanup_stale_pending_messages() {
    log "⏭️  跳过：pending/processing 消息保留（Claude-Mem 自动恢复机制）"
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
    # 清理已标记为失败的消息（30 天以上）
    # 这些是 Claude-Mem 明确标记为失败的，可以安全删除

    log "清理已失败的消息（>30天）..."

    local CUTOFF_TIMESTAMP=$(($(date +%s) - 2592000))  # 30 天前

    local FAILED_COUNT=$(sqlite3 "$DB_PATH" <<SQL
SELECT COUNT(*) FROM pending_messages
WHERE status = 'failed'
  AND (failed_at_epoch IS NOT NULL
       AND failed_at_epoch < $CUTOFF_TIMESTAMP);
SQL
)

    if [ "$FAILED_COUNT" -gt 0 ]; then
        log "⚠️  发现 $FAILED_COUNT 条已失败消息（>30天）"

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
