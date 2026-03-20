# Claude-Mem Pending Messages 问题分析与解决方案

## 问题描述

### 症状
- `pending_messages` 表中的记录不断增加
- 许多消息永远卡在 `pending` 或 `processing` 状态
- 占用数据库空间，可能导致队列阻塞

### 根本原因

Claude-Mem 没有内置的自动清理机制。正常的消息处理流程：

```
Hook 创建消息 → Worker 处理 → 标记为 processed → 自动删除
```

但当 Worker 无法完成处理时，消息会永久卡在：

```
pending → processing → (失败) → 永久堆积
```

### 为什么会堆积？

1. **Worker 处理失败**
   - 网络问题导致处理超时
   - 内存溢出或崩溃
   - 数据格式错误无法解析

2. **历史会话遗留**
   - 历史会话的 summarize 任务未完成
   - 父会话已删除，但消息未清理

3. **重试机制限制**
   - Worker 重试有上限
   - 超过上限的消息被放弃，但未删除

---

## 解决方案架构

### 三层防线

#### 第 1 层：自动清理守护（auto-cleanup.sh）

每天午夜自动运行，清理：

| 类型 | 条件 | 清理阈值 |
|------|------|---------|
| **卡住的消息** | 状态 = pending/processing | 24h 无进展 + 重试 >= 3 次 |
| **孤立消息** | 父会话已删除 | 任何时间 |
| **失败消息** | 状态 = failed | 7 天未更新 |

**特点**：
- ✅ 自动备份（防止误删）
- ✅ 只保留最近 30 个清理备份
- ✅ 详细日志记录

#### 第 2 层：定期维护（maintenance.sh）

每周手动执行完整维护：

```bash
cm-maint full
# 或指定清理数据
cm-maint cleanup 5000
```

#### 第 3 层：监控告警（monitor.sh）

实时监控数据库大小，防止过度增长：

| 大小 | 状态 | 行动 |
|------|------|------|
| < 200MB | ✅ | 无需操作 |
| 200-500MB | ⚠️ | 可考虑清理 |
| 500MB-1GB | 🚨 | 建议立即清理 |
| > 1GB | 🚨 | 必须处理 |

---

## 使用方法

### 立即执行自动清理

```bash
# 交互菜单
cm-run
# 选择 [6] 🧹 自动清理卡住消息

# 或直接命令
cm-run auto-cleanup
```

### 启用每日自动清理守护

```bash
cm-run
# 选择 [9] ⚙️ 启动自动清理守护

# 或直接命令
cm-run cleanup-daemon
```

### 验证守护程序

```bash
# 查看启用的守护
launchctl list | grep claude-mem

# 查看清理日志
tail -f ~/.claude-mem/auto-cleanup.log

# 查看错误日志
cat ~/.claude-mem/auto-cleanup.stderr.log
```

---

## 清理机制详解

### 1. 卡住的消息清理

**定义**：消息满足以下所有条件：
- 状态：`pending` 或 `processing`
- 最后更新：> 24 小时前
- 重试次数：>= 3 次（已尝试过但失败）

**清理方式**：
```sql
DELETE FROM pending_messages
WHERE (status = 'pending' OR status = 'processing')
  AND (started_processing_at_epoch < [24h_ago])
  AND retry_count >= 3
```

**示例**：
```
消息 #123: 24 小时前进入 processing，已重试 5 次 → 删除
消息 #456: 12 小时前进入 processing，重试 2 次 → 保留（还有机会）
```

### 2. 孤立消息清理

**定义**：消息的父会话已被删除

**清理方式**：
```sql
DELETE FROM pending_messages pm
WHERE NOT EXISTS (
    SELECT 1 FROM sdk_sessions ss
    WHERE ss.id = pm.session_db_id
)
```

**示例**：
```
会话 #S123 已删除，但其 pending_message #789 仍存在 → 删除
```

### 3. 失败消息清理

**定义**：消息状态为 `failed` 且 7 天未更新

**清理方式**：
```sql
DELETE FROM pending_messages
WHERE status = 'failed'
  AND (failed_at_epoch < [7d_ago])
```

**示例**：
```
消息 #999: 失败于 10 天前 → 删除
消息 #888: 失败于 3 天前 → 保留（可能还要查看）
```

---

## 日志和监控

### 自动清理日志

位置：`~/.claude-mem/auto-cleanup.log`

```
[2026-03-21 00:00:00] === 自动清理开始 ===
[2026-03-21 00:00:01] 开始清理卡住的 pending_messages...
[2026-03-21 00:00:02] ✅ 没有卡住的消息需要清理
[2026-03-21 00:00:03] 清理孤立消息（对应会话已删除）...
[2026-03-21 00:00:04] ✅ 没有孤立消息
[2026-03-21 00:00:05] === 自动清理结束 ===
```

### 备份文件

位置：`~/.claude-mem/claude-mem.db.backup_before_*_cleanup_*`

```bash
# 查看所有清理备份
ls -la ~/.claude-mem/claude-mem.db.backup_before_*

# 恢复备份（如需要）
cp ~/.claude-mem/claude-mem.db.backup_before_stale_cleanup_20260321_000001 \
   ~/.claude-mem/claude-mem.db
```

### 故障排查

```bash
# 检查守护进程状态
launchctl list | grep auto-cleanup

# 查看 launchd 错误
cat ~/.claude-mem/auto-cleanup.stderr.log

# 手动运行清理并查看详细输出
~/.claude/projects/macbook-tools/claude-mem/auto-cleanup.sh

# 查看清理前后的数据库状态
cm-run stats
```

---

## 风险和安全性

### 安全措施

✅ **自动备份**
- 每次清理前自动创建备份
- 保留最近 30 个备份（不占用过多空间）
- 清理失败时保持原数据

✅ **保守的清理策略**
- 只清理明确失败的消息
- 卡住 24+ 小时才清理（给足时间恢复）
- 重试次数 >= 3 才认为已放弃

✅ **完整的审计日志**
- 所有清理操作记录
- 可追溯何时清理了什么
- 便于分析问题

### 什么不会被删除？

❌ **<12 小时的 pending 消息**
- 可能还在处理中

❌ **重试次数 < 3 的消息**
- 还有重试机会

❌ **< 7 天的 failed 消息**
- 可能需要手动调查

❌ **有对应会话的孤立消息**
- 父会话仍存在

---

## 配置自定义

### 修改清理阈值

编辑 `auto-cleanup.sh` 的时间常量：

```bash
# 卡住消息阈值（默认 24 小时）
CUTOFF_TIMESTAMP=$(($(date +%s) - 86400))
# 改为 12 小时：24*60*60 = 86400，12h = 43200
CUTOFF_TIMESTAMP=$(($(date +%s) - 43200))

# 失败消息阈值（默认 7 天）
CUTOFF_TIMESTAMP=$(($(date +%s) - 604800))
# 改为 3 天：7*24*60*60 = 604800，3d = 259200
CUTOFF_TIMESTAMP=$(($(date +%s) - 259200))
```

### 修改清理频率

编辑 `com.kryss.claude-mem.auto-cleanup.plist`:

```xml
<!-- 改为每 6 小时运行 -->
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>0</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>6</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <dict>
        <key>Hour</key>
        <integer>18</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

然后重新加载：
```bash
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.auto-cleanup.plist
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.auto-cleanup.plist
```

---

## 快速参考

| 场景 | 命令 |
|------|------|
| 立即清理卡住消息 | `cm-run auto-cleanup` |
| 启用每日自动清理 | `cm-run cleanup-daemon` |
| 完整维护（含备份和清理） | `cm-run full` |
| 查看清理日志 | `tail -f ~/.claude-mem/auto-cleanup.log` |
| 禁用自动清理 | `launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.auto-cleanup.plist` |
| 恢复旧数据 | `cp ~/.claude-mem/claude-mem.db.backup_before_*` |

---

## FAQ

**Q: 清理会删除有用的数据吗？**
A: 不会。只删除明确失败的消息（重试 3+ 次、24h+ 无进展）。

**Q: 能手动运行清理吗？**
A: 可以，运行 `cm-run auto-cleanup` 或直接调用脚本。

**Q: 清理后能恢复吗？**
A: 可以，有自动备份。运行 `cp ~/.claude-mem/claude-mem.db.backup_before_* ~/.claude-mem/claude-mem.db`。

**Q: pending_messages 多少条算正常？**
A: 0-100 条正常。超过 500 条说明有积压，应该执行清理。

**Q: 为什么有些消息永久卡住？**
A: Claude-Mem worker 可能处理失败或超时。清理守护会自动移除这些卡住的消息。

**Q: 可以跳过自动清理直接禁用？**
A: 可以，但不建议。禁用后需手动定期清理，否则队列会逐渐膨胀。

---

## 性能影响

### 清理性能
- **运行时间**：5-10 秒（典型）
- **锁定数据库**：< 1 秒（事务内）
- **I/O 影响**：最小化（只涉及必要表）

### 对 Claude Code 的影响
- 清理在后台运行（launchd）
- 不阻塞前台任务
- 只在清理中瞬间锁定数据库

---

## 最佳实践

1. **启用自动守护**
   ```bash
   cm-run cleanup-daemon
   ```

2. **定期监控大小**
   ```bash
   cm-run stats
   ```

3. **周1 完整维护**
   ```bash
   cm-run full
   ```

4. **监听告警**
   - 查看 `~/.claude-mem/alerts.log`
   - 设置 macOS 系统通知

5. **定期备份**
   - `~/.claude-mem/backups/` 存在即可
   - maintenance.sh 自动管理

---

## 相关文件

- `auto-cleanup.sh` - 清理脚本
- `com.kryss.claude-mem.auto-cleanup.plist` - 守护配置
- `run.sh` - 一键菜单（包含清理选项）
- `MAINTENANCE.md` - 完整维护指南
- `SETUP_GUIDE.md` - 安装和使用指南
