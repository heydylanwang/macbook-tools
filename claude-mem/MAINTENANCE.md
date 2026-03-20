# Claude-Mem 维护指南

## 快速开始

```bash
# 显示数据库统计信息
./maintenance.sh stats

# 完整维护（备份 → 检查 → 统计）
./maintenance.sh full

# 仅创建备份
./maintenance.sh backup

# 检查数据库大小和健康状态
./maintenance.sh check
```

## 脚本说明

### maintenance.sh - 核心维护工具

| 命令 | 说明 | 何时使用 |
|------|------|---------|
| `backup` | 创建数据库备份 | 定期备份或清理前 |
| `check` | 检查大小并告警 | 定期健康检查 |
| `cleanup [count]` | 清理过期数据 | 数据库超过 200MB |
| `stats` | 显示统计信息 | 了解当前状态 |
| `full` | 完整维护流程 | 每周运行一次 |

### monitor.sh - 自动监控

定期检查数据库大小，触发告警：
- **⚠️ INFO**: 200MB (接近阈值)
- **⚠️ WARNING**: 500MB (建议清理)
- **🚨 CRITICAL**: 1GB (必须处理)

### 自动化设置

#### macOS - 使用 launchd

```bash
# 1. 让脚本可执行
chmod +x ~/projects/macbook-tools/claude-mem/{maintenance,monitor}.sh

# 2. 安装 launchd 配置
mkdir -p ~/Library/LaunchAgents
cp ~/projects/macbook-tools/claude-mem/com.kryss.claude-mem.monitor.plist \
   ~/Library/LaunchAgents/

# 3. 启动监控
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist

# 4. 检查状态
launchctl list | grep claude-mem

# 5. 卸载（如需要）
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

#### Linux/其他 - 使用 cron

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每天 9 点运行）
0 9 * * * $HOME/projects/macbook-tools/claude-mem/monitor.sh >> $HOME/.claude-mem/cron.log 2>&1

# 每周一次完整维护（周日 10 点）
0 10 * * 0 $HOME/projects/macbook-tools/claude-mem/maintenance.sh full >> $HOME/.claude-mem/cron.log 2>&1
```

## 数据库告警阈值

| 大小 | 状态 | 建议操作 |
|------|------|---------|
| < 200MB | ✅ 正常 | 无需操作 |
| 200-500MB | ⚠️ 关注 | 可考虑清理 |
| 500MB-1GB | ⚠️ 告警 | 建议立即清理 |
| > 1GB | 🚨 危险 | 必须处理 |

## 清理策略

### 安全清理流程

1. **创建备份**（自动）
   ```bash
   ./maintenance.sh backup
   ```

2. **查看统计**
   ```bash
   ./maintenance.sh stats
   ```

3. **执行清理**（保留最近 5000 条）
   ```bash
   ./maintenance.sh cleanup 5000
   ```

### 备份管理

- 自动保留最近 **10 个** 备份
- 备份位置：`~/.claude-mem/backups/`
- 备份时间戳：`claude-mem.db.backup_YYYYMMDD_HHMMSS`

### 清理规则

- **observations**: 保留最近 5000 条（约 1-2 年数据）
- **pending_messages**: 只保留最近 7 天的待处理消息（最多 200 条）

## 日志文件

| 日志 | 路径 | 用途 |
|------|------|------|
| 维护日志 | `~/.claude-mem/maintenance.log` | 备份、清理操作记录 |
| 告警日志 | `~/.claude-mem/alerts.log` | 大小检查告警 |
| launchd stdout | `~/.claude-mem/monitor.stdout.log` | 监控程序输出 |
| launchd stderr | `~/.claude-mem/monitor.stderr.log` | 错误信息 |

## 故障排查

### 问题：脚本权限不足

```bash
chmod +x ~/projects/macbook-tools/claude-mem/maintenance.sh
chmod +x ~/projects/macbook-tools/claude-mem/monitor.sh
```

### 问题：launchd 不执行

```bash
# 检查配置是否有效
launchctl list | grep claude-mem

# 查看错误日志
cat ~/.claude-mem/monitor.stderr.log

# 手动测试脚本
~/projects/macbook-tools/claude-mem/monitor.sh

# 重新加载配置
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

### 问题：sqlite3 命令失败

- 确保 sqlite3 已安装：`which sqlite3`
- 检查数据库文件权限：`ls -l ~/.claude-mem/claude-mem.db`
- 尝试手动查询：`sqlite3 ~/.claude-mem/claude-mem.db ".tables"`

## 当前数据库状态

```
📊 Claude-Mem 统计
===================
observations:     613 条
pending_messages:  27 条
user_prompts:     413 条
sdk_sessions:     207 条
session_summaries: 309 条
📁 数据库大小:    4.4MB (✅ 安全范围)
```

运行 `./maintenance.sh stats` 查看最新状态。

## 推荐维护计划

| 频率 | 操作 | 命令 |
|------|------|------|
| 每日 | 自动监控大小 | launchd 自动运行 |
| 每周 | 完整维护 | `./maintenance.sh full` |
| 每月 | 大数据清理 | `./maintenance.sh cleanup 5000` |
| 手动 | 问题处理 | 根据告警执行 |
