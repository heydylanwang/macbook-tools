# Claude-Mem 安全性分析：为什么我们改变了清理策略

## 问题

我最初创建了一个 auto-cleanup 脚本，计划每天清理"卡住"的 pending_messages（24h+ 无进展）。

但你提出了一个关键问题：

> **如果当前遗留的消息，第二天在启动 Claude 时，可能 claude-mem 就会继续上次工作，可以将 pending 状态转变呢？**

这个问题促使我深入研究 Claude-Mem 的源代码。

---

## 发现：Claude-Mem 有自动恢复机制

### 关键代码片段

在 Claude-Mem worker-service.cjs 中：

```javascript
// 当 Worker 启动时（每次 Claude 重启）：
resetStaleProcessingMessages(0)  // 阈值是 0ms，即立即重置

// 执行效果：
UPDATE pending_messages
SET status = 'pending', started_processing_at_epoch = NULL
WHERE status = 'processing' AND started_processing_at_epoch < ?
```

### 这意味着什么？

1. **当 Claude 重启时**
   - Worker 自动启动
   - `resetStaleProcessingMessages()` 被调用
   - 所有卡在 `processing` 的消息变回 `pending`
   - 可以继续处理

2. **消息生命周期**
   ```
   Hook 创建 → status = 'pending'
   Worker 处理 → status = 'processing'
   处理完成 → DELETE（成功）或 status = 'failed'（失败）
   Worker 重启 → 'processing' 重置为 'pending'（恢复机制！）
   ```

3. **用户的场景完全可能发生**
   ```
   Day 1: 消息 #123 进入 processing（24h 无进展）
   Day 2: Claude 重启 → Worker 启动 → 消息自动重置为 pending
   Day 2: 消息继续被处理 → 可能成功！
   ```

---

## 为什么我们不能删除 pending/processing 消息

### 问题 1：我们无法区分"失效"和"等待中"

一个消息在 24 小时内没有进展，可能是因为：

✅ **不是失效的原因**：
- 网络问题导致超时，但 Worker 会重试
- 消息故意等待（某些操作需要时间）
- 等待其他消息完成
- Claude 被暂停了（睡眠模式）
- Worker 崩溃后重启（自动恢复！）

❌ **可能失效的原因**：
- Worker 处理错误
- 但即使失效，Claude 重启后会再试一次

### 问题 2：无法确定消息一定无法恢复

```javascript
// Claude-Mem 的设计理念：
// "如果你不确定，就重试"

resetStaleProcessingMessages()  // 每次启动都重新尝试
```

### 问题 3：我们可能误删重要数据

如果我们删除了一个"看起来"失效但其实还能处理的消息：
- 数据丢失
- 无法追溯
- 破坏 Claude-Mem 的自动恢复机制

---

## 新的（安全的）清理策略

### 只清理两种消息

#### 1. 孤立消息（✅ 完全安全）

定义：消息的父会话已被删除

```sql
DELETE FROM pending_messages pm
WHERE NOT EXISTS (
    SELECT 1 FROM sdk_sessions ss
    WHERE ss.id = pm.session_db_id
)
```

为什么安全：
- 如果会话被删除了，这个消息永远无法处理
- 没有恢复的可能性
- 100% 可以删除

#### 2. 失败消息（✅ 相对安全）

定义：消息状态为 `failed`，且 30+ 天未更新

```sql
DELETE FROM pending_messages
WHERE status = 'failed'
  AND failed_at_epoch < [30_days_ago]
```

为什么相对安全：
- `failed` 状态表示 Claude-Mem 已经放弃了这个消息
- 30 天足够让用户看到失败原因并处理
- 30 天后可以安全归档

### 不清理的消息

❌ **pending 消息** - 随时可能被处理
❌ **processing 消息** - Worker 重启时会恢复为 pending

---

## 清理计划

### 频率
- **每周一次**（周日午夜）
- 足够清理垃圾，但不会过于频繁

### 流程
1. 清理孤立消息（父会话已删除）
2. 清理失败消息（>30 天）
3. 自动备份（防止误删）
4. 保留日志（审计追踪）

### 何时手动清理
```bash
# 需要立即清理时
cm-run auto-cleanup

# 完整维护（包括备份和检查）
cm-run full
```

---

## 对比：旧策略 vs 新策略

| 方面 | 旧策略 ❌ | 新策略 ✅ |
|------|----------|----------|
| 清理 pending | 是（危险！） | 否（保留） |
| 清理 processing | 是（危险！） | 否（保留） |
| 清理孤立 | 是 | 是 |
| 清理失败 | 7+ 天 | 30+ 天 |
| 频率 | 每天 | 每周 |
| 自动恢复风险 | 高 | 低 |
| 数据丢失风险 | 高 | 低 |

---

## 为什么这很重要

Claude-Mem 的设计理念是：

> **"自动恢复比自动删除更重要"**

如果我们的清理脚本与 Claude-Mem 的自动恢复机制冲突，就会：

1. ❌ 破坏 Claude-Mem 的容错能力
2. ❌ 导致数据意外丢失
3. ❌ 让 pending_messages 堆积变得更糟（因为旧消息被删除，新消息继续增加）

新策略尊重 Claude-Mem 的设计，让它自己处理消息恢复。

---

## 验证

如何验证这个决定是正确的？

```bash
# 1. 查看当前待处理消息
cm-run stats

# 2. 重启 Claude Code
# (或 cm-worker restart)

# 3. 再次查看待处理消息
cm-run stats

# 观察：一些 processing 消息应该变为 pending（恢复了！）
```

这证实了 Claude-Mem 的自动恢复机制在工作。

---

## 结论

✅ **我们移除了危险的自动清理逻辑**

❌ **新策略不会清理可能可恢复的消息**

✅ **只清理已确定无法恢复的消息**

✅ **让 Claude-Mem 的自动恢复机制正常工作**

这是更保守、更安全的做法。

---

## 进一步阅读

- `PENDING_MESSAGES.md` - 完整的问题分析和解决方案
- `auto-cleanup.sh` - 实际的清理脚本（只清理安全的消息）
- Claude-Mem 源代码：`resetStaleProcessingMessages()` 函数
