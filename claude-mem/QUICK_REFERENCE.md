# Claude-Mem 快速参考卡

## 🚀 日常命令

```bash
# 查看数据库统计
cm-maint stats

# 完整维护（每周推荐）
cm-maint full

# 查看服务状态
cm-status

# 查看可视化界面
cm-viewer
```

## 📊 监控和告警

```bash
# 创建备份（清理前必须做）
cm-maint backup

# 检查数据库大小和健康状态
cm-maint check

# 查看监控日志
tail -f ~/.claude-mem/alerts.log
tail -f ~/.claude-mem/maintenance.log
```

## 🧹 数据清理（安全流程）

```bash
# 1️⃣ 查看当前统计
cm-maint stats

# 2️⃣ 创建备份
cm-maint backup

# 3️⃣ 检查大小（如果 >200MB，执行清理）
cm-maint check

# 4️⃣ 执行清理（保留最近 5000 条）
cm-maint cleanup 5000
```

## ⚙️ 自动监控设置

```bash
# 安装 launchd 自动监控（macOS）
mkdir -p ~/Library/LaunchAgents
cp ~/projects/macbook-tools/claude-mem/com.kryss.claude-mem.monitor.plist \
   ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist

# 验证已安装
launchctl list | grep claude-mem

# 卸载（如需要）
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

## 📈 数据库大小告警

| 大小 | 状态 | 建议 |
|------|------|------|
| < 200MB | ✅ | 无需操作 |
| 200-500MB | ⚠️ | 可考虑清理 |
| 500MB-1GB | 🚨 | 建议立即清理 |
| > 1GB | 🚨 | 必须处理 |

## 🔍 故障排查

```bash
# 测试脚本是否可用
~/projects/macbook-tools/claude-mem/maintenance.sh stats

# 查看脚本权限
ls -l ~/projects/macbook-tools/claude-mem/{maintenance,monitor}.sh

# 重新设置权限
chmod +x ~/projects/macbook-tools/claude-mem/{maintenance,monitor}.sh

# 手动测试监控
~/projects/macbook-tools/claude-mem/monitor.sh

# 查看 launchd 日志
log stream --predicate 'eventMessage contains[cd] "claude-mem"' --level debug
```

## 📝 配置文件位置

| 内容 | 位置 |
|------|------|
| 数据库 | `~/.claude-mem/claude-mem.db` |
| 备份 | `~/.claude-mem/backups/` |
| 维护日志 | `~/.claude-mem/maintenance.log` |
| 告警日志 | `~/.claude-mem/alerts.log` |
| 监控配置 | `~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist` |

## 🛠️ 完整脚本说明

详见 `MAINTENANCE.md`

## 📚 相关命令

```bash
# claude-mem worker 命令
cm-worker health    # 检查健康状态
cm-worker status    # 查看运行状态
cm-worker stats     # 查看统计信息
cm-worker queue     # 查看任务队列
cm-worker logs      # 查看日志
cm-worker start     # 启动服务
cm-worker stop      # 停止服务
cm-worker restart   # 重启服务
```
