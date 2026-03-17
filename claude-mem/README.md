# claude-mem 配置指南

claude-mem 是 Claude Code 的持久化记忆系统，基于 MCP 协议。

## 📦 安装

```bash
./install.sh
```

## 🎯 功能特性

- **跨会话记忆**：自动记录对话中的重要信息
- **智能检索**：通过语义搜索快速找到历史记录
- **项目隔离**：不同项目的记忆独立存储
- **Token 优化**：3 层查询机制节省 10x Token

## ⌨️ 常用命令

```bash
# 启动 Worker 服务
cm-start

# 查看服务状态
cm-status

# 查看统计信息
cm-stats

# 查看队列
cm-queue

# 打开可视化界面
cm-viewer

# 查看日志
cm-logs

# 重启服务
cm-restart

# 停止服务
cm-stop
```

## 🔧 配置说明

### MCP 配置
在 `~/.claude/settings/mcp.json` 中配置：

```json
{
  "mcpServers": {
    "claude-mem": {
      "command": "bun",
      "args": ["/path/to/claude-mem/worker-service.cjs"]
    }
  }
}
```

### 数据存储
- 数据库：`~/.claude/plugins/cache/thedotmack/claude-mem/*/db/`
- 不需要迁移到新机器（每台机器独立记忆）

## 📚 使用技巧

### 在 Claude 对话中使用

```bash
# 搜索记忆
search("yazi 配置")

# 获取详细信息
get_observations([123, 456])

# 查看时间线
timeline(anchor=123)
```

### 3 层查询工作流

1. **search()** - 获取索引和 ID（~50-100 tokens/结果）
2. **timeline()** - 获取上下文（围绕感兴趣的结果）
3. **get_observations()** - 获取完整详情（仅针对筛选后的 ID）

## 💡 最佳实践

1. **开始工作前先查记忆**：避免重复分析
2. **记忆中有结论则不重复读文件**：节省 Token
3. **按主题组织记忆**：便于后续检索
4. **定期查看统计**：了解记忆增长情况
