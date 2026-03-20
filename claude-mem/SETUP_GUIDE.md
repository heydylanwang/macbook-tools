# Claude-Mem 维护系统完整指南

## 📦 快速开始

### 一、自动安装（推荐）

```bash
cd ~/projects/macbook-tools
./install-all.sh
```

这会：
1. ✅ 安装 claude-mem 插件
2. ✅ 创建 cm-worker 快捷脚本
3. ✅ 添加 zsh 别名
4. ✅ **自动启用每日监控**（launchd）

### 二、手动安装

```bash
# 安装 claude-mem 插件
cd ~/projects/macbook-tools/claude-mem
./install.sh

# 手动启用日监控（macOS）
mkdir -p ~/Library/LaunchAgents
cp com.kryss.claude-mem.monitor.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

---

## 🎯 日常使用

### 最快速的方式

```bash
# 交互式菜单（推荐新手）
cm-run

# 或直接命令
cm-run stats        # 查看统计
cm-run check        # 检查健康状态
cm-run backup       # 创建备份
cm-run cleanup      # 清理过期数据
cm-run logs         # 查看日志
```

### 命令行快速访问

```bash
# 维护脚本
cm-maint stats      # 显示统计信息
cm-maint full       # 完整维护流程
cm-maint backup     # 只创建备份
cm-maint check      # 只检查大小
cm-maint cleanup    # 清理过期数据

# Claude-Mem worker 命令
cm-status           # 查看服务状态
cm-stats            # 查看服务统计
cm-viewer           # 打开可视化界面
cm-logs             # 查看服务日志
cm-health           # 检查健康状态
```

---

## 🔧 系统组件说明

### 1. **maintenance.sh** - 核心维护工具

| 功能 | 命令 | 何时用 |
|------|------|--------|
| 显示统计 | `maintenance.sh stats` | 了解数据库情况 |
| 创建备份 | `maintenance.sh backup` | 清理前必做 |
| 检查大小 | `maintenance.sh check` | 定期监控 |
| 清理数据 | `maintenance.sh cleanup 5000` | >200MB 时 |
| 完整维护 | `maintenance.sh full` | 每周一次 |

**备份策略**：
- 自动保留最近 **10 个**备份
- 位置：`~/.claude-mem/backups/`
- 时间戳格式：`claude-mem.db.backup_YYYYMMDD_HHMMSS`

**清理规则**：
- 保留最近 5000 条 observations（1-2 年数据）
- 清理 7 天以前的 pending_messages
- 删除前必须有备份（自动检查）

### 2. **monitor.sh** - 自动监控脚本

定期检查数据库大小并触发告警：

| 大小 | 状态 | 告警 |
|------|------|------|
| < 200MB | ✅ 正常 | 无 |
| 200-500MB | ⚠️ 关注 | INFO |
| 500MB-1GB | 🚨 告警 | WARNING |
| > 1GB | 🚨 危险 | CRITICAL |

告警方式：
- 📝 写入日志：`~/.claude-mem/alerts.log`
- 🔔 系统通知（macOS）

### 3. **run.sh** - 一键执行菜单

交互式菜单，适合日常操作：

```bash
cm-run              # 进入交互菜单
cm-run stats        # 直接执行命令
cm-run monitor-setup  # 设置自动监控
```

菜单选项：
```
[1] 📈 显示统计信息
[2] 💾 创建备份
[3] 🔍 检查健康状态
[4] 🧹 清理过期数据
[5] 🔄 完整维护流程
[6] 📋 查看维护日志
[7] 🚀 启动自动监控
[0] 退出
```

### 4. **com.kryss.claude-mem.monitor.plist** - launchd 配置

自动化监控配置（macOS）：
- **频率**：每 24 小时（可编辑）
- **脚本**：monitor.sh
- **日志**：`~/.claude-mem/monitor.*.log`

---

## 📊 数据库状态监控

### 实时查询

```bash
# 快速统计
cm-run stats

# 详细信息
sqlite3 ~/.claude-mem/claude-mem.db <<'SQL'
SELECT COUNT(*) as observations FROM observations;
SELECT COUNT(*) as pending FROM pending_messages;
SELECT COUNT(*) as prompts FROM user_prompts;
SELECT COUNT(*) as sessions FROM sdk_sessions;
SQL
```

### 日志文件

| 日志 | 位置 | 内容 |
|------|------|------|
| 维护日志 | `~/.claude-mem/maintenance.log` | 备份、清理操作 |
| 告警日志 | `~/.claude-mem/alerts.log` | 大小检查告警 |
| launchd stdout | `~/.claude-mem/monitor.stdout.log` | 监控输出 |
| launchd stderr | `~/.claude-mem/monitor.stderr.log` | 错误信息 |

---

## 🧹 数据清理完整流程

### 安全清理步骤

```bash
# 第 1 步：查看当前状态
cm-run stats

# 第 2 步：如果 >200MB，创建备份
cm-run backup

# 第 3 步：检查告警阈值
cm-run check

# 第 4 步：执行清理（保留 5000 条）
cm-run cleanup

# 第 5 步：验证结果
cm-run stats
```

### 自定义清理参数

```bash
# 保留最近 3000 条（更激进）
cm-maint cleanup 3000

# 保留最近 10000 条（更保守）
cm-maint cleanup 10000
```

### 清理影响

| 参数 | observations | pending_messages | 备注 |
|------|--------------|------------------|------|
| 5000 | 保留最近5k条 | 清理7天以前 | 默认推荐 |
| 3000 | 保留最近3k条 | 清理7天以前 | 激进清理 |
| 10000 | 保留最近10k条 | 不清理 | 保守方案 |

---

## 🔍 故障排查

### 问题 1: 脚本权限不足

```bash
# 解决
chmod +x ~/projects/macbook-tools/claude-mem/{maintenance,monitor,run}.sh
chmod +x ~/projects/macbook-tools/install-all.sh
```

### 问题 2: cm-run 命令找不到

```bash
# 检查别名
alias | grep cm-run

# 重新加载配置
source ~/.zshrc

# 或手动运行
~/projects/macbook-tools/claude-mem/run.sh
```

### 问题 3: launchd 监控不工作

```bash
# 验证配置
launchctl list | grep claude-mem

# 查看错误
cat ~/.claude-mem/monitor.stderr.log

# 重新安装
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist 2>/dev/null || true
cp ~/projects/macbook-tools/claude-mem/com.kryss.claude-mem.monitor.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

### 问题 4: sqlite3 命令失败

```bash
# 验证 sqlite3
which sqlite3

# 检查数据库权限
ls -l ~/.claude-mem/claude-mem.db

# 手动测试
sqlite3 ~/.claude-mem/claude-mem.db ".tables"
```

---

## 📈 推荐维护计划

### 日常（自动）
- launchd 每天自动运行 monitor.sh
- 发现问题时发送系统通知

### 每周一次
```bash
cm-run full    # 完整维护（备份→检查→统计）
```

### 每月一次
```bash
# 如果 >500MB，执行清理
cm-run cleanup
```

### 紧急情况
```bash
# 数据库 >1GB，立即处理
cm-run cleanup 3000   # 激进清理（保留 3000 条）
```

---

## 🎓 高级用法

### 自定义监控频率

编辑 `com.kryss.claude-mem.monitor.plist`:

```xml
<!-- 改为每 6 小时运行 -->
<key>StartInterval</key>
<integer>21600</integer>

<!-- 或改为每天 9 点运行 -->
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

然后重新加载：
```bash
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
launchctl load ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

### 导出和恢复备份

```bash
# 导出备份到外部存储
cp ~/.claude-mem/backups/claude-mem.db.backup_* /Volumes/ExternalDrive/

# 从备份恢复
cp /Volumes/ExternalDrive/claude-mem.db.backup_YYYYMMDD_HHMMSS ~/.claude-mem/claude-mem.db
```

### 数据库直接查询

```bash
# 查看最大的 observations
sqlite3 ~/.claude-mem/claude-mem.db <<'SQL'
SELECT
  id,
  LENGTH(content) as size_bytes,
  created_at
FROM observations
ORDER BY LENGTH(content) DESC
LIMIT 10;
SQL
```

---

## 📚 相关文档

- **MAINTENANCE.md** - 详细的维护指南
- **QUICK_REFERENCE.md** - 命令速查卡
- **claude-mem 官方文档** - https://github.com/thedotmack/claude-mem

---

## ✅ 检查清单

安装后验证：

- [ ] `cm-run` 命令可用
- [ ] `cm-run stats` 能显示统计
- [ ] `~/.claude-mem/maintenance.log` 存在
- [ ] `~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist` 存在
- [ ] `launchctl list | grep claude-mem` 有输出
- [ ] `~/.claude-mem/backups/` 目录存在且有备份

运行：
```bash
cm-run          # 进入菜单，选择 [7] 验证监控
cm-run full     # 完整维护验证所有功能
```

---

## 💡 常见问题

**Q: 多久需要清理一次？**
A: 当数据库 >200MB 时考虑清理。正常情况下，每月清理一次。

**Q: 清理会丢失数据吗？**
A: 不会。清理只删除超过保留期的旧数据，关键的新数据保留完整。

**Q: 能关闭自动监控吗？**
A: 可以，运行：
```bash
launchctl unload ~/Library/LaunchAgents/com.kryss.claude-mem.monitor.plist
```

**Q: 告警会怎样通知我？**
A: 自动写入日志，并在 macOS 上显示系统通知。

**Q: 备份会占用很多空间吗？**
A: 不会。系统只保留最近 10 个备份（~44MB），自动删除旧备份。
