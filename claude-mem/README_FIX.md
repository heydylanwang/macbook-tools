# Claude-Mem 清理策略修复说明

## 问题

初始的 `auto-cleanup.sh` 计划每天删除"卡住"的 pending_messages（24h+ 无进展）。

但这个策略**不安全**，原因：Claude-Mem 有自动恢复机制。

## 解决方案

修改了清理策略，现在：

### ✅ 清理以下消息（安全）
1. **孤立消息** - 父会话已删除（无法恢复）
2. **失败消息** - 状态为 `failed`，且 30+ 天未更新（已被 Claude-Mem 放弃）

### ❌ 保留以下消息（可能恢复）
1. **pending 消息** - 随时可能被继续处理
2. **processing 消息** - Claude 重启时会自动重置为 pending（恢复机制！）

## 频率

- **旧**：每天运行
- **新**：每周一次（周日午夜）

## 技术原因

Claude-Mem 在 Worker 启动时调用 `resetStaleProcessingMessages()`：

```javascript
// 当 Claude 重启时：
UPDATE pending_messages
SET status = 'pending', started_processing_at_epoch = NULL
WHERE status = 'processing'
// 效果：卡住的 processing 消息 → 变回 pending
```

这意味着：
- 如果你的消息"卡住"了 24 小时
- 第二天重启 Claude 时，它会自动恢复
- 可能继续处理并成功

所以我们**不能假设 24h+ 无进展的消息已失效**。

## 使用方法

```bash
# 立即清理（仅清理安全的消息）
cm-run auto-cleanup

# 启用周一次自动清理守护
cm-run cleanup-daemon

# 查看统计
cm-run stats

# 完整维护
cm-run full
```

## 更详细信息

- `SAFETY_ANALYSIS.md` - 为什么做这个改变
- `PENDING_MESSAGES.md` - 完整的问题分析
- `auto-cleanup.sh` - 实际的清理脚本

## 当前状态

✅ 清理策略：安全优先
✅ 每周自动清理：已启用
✅ 数据保护：自动备份
✅ 监控告警：已启用（每天检查大小）

## 是否还会有堆积？

不会。虽然我们不再删除 pending/processing 消息，但：

1. **Claude-Mem 自己处理恢复** - 消息继续被处理
2. **只清理永远无法处理的消息** - 孤立 + 失败消息
3. **每周一次清理** - 防止垃圾积累
4. **监控告警** - 数据库变大时会通知你

所以：
- ✅ 不会误删重要消息
- ✅ 不会堆积垃圾数据
- ✅ Claude-Mem 继续工作
- ✅ 你的数据安全
