# Claude Code 配置指南

Claude Code 是 Anthropic 官方的 AI 编程助手 CLI 工具。

## 📦 安装

```bash
./install.sh
```

## 🎯 功能特性

- **AI 编程助手**：代码生成、重构、调试
- **持久化记忆**：跨会话记住项目上下文
- **技能系统**：可扩展的命令插件
- **MCP 支持**：Model Context Protocol 集成

## ⌨️ 常用命令

```bash
# 启动对话
claude chat

# 指定模型
claude chat --model opus    # 最强模型
claude chat --model sonnet  # 平衡模型
claude chat --model haiku   # 快速模型

# 跳过权限确认（危险）
claude chat --dangerously-skip-permissions

# 查看帮助
claude --help
```

## 🔧 配置文件

### 全局配置
- `~/.claude/CLAUDE.md` - 全局指令规则
- `~/.claude/settings.json` - 权限和插件配置
- `~/.claude/memory/` - 自动记忆目录

### 项目配置
- `.claude/CLAUDE.md` - 项目特定指令
- `.claudeignore` - 忽略文件规则

## 🎨 快捷键（对话中）

| 快捷键 | 功能 |
|--------|------|
| `/help` | 查看帮助 |
| `/clear` | 清空对话 |
| `/quit` | 退出 |
| `/fast` | 切换快速模式 |

## 📚 Skills（技能命令）

```bash
/commit          # 智能 Git 提交
/simplify        # 代码质量审查
/claude-api      # Claude API 开发
/loop 5m <cmd>   # 定时执行命令
```

## 🔐 环境变量

```bash
# OAuth 登录（推荐）
claude auth login

# API Key 方式
export ANTHROPIC_API_KEY="sk-ant-..."

# 代理配置
export ANTHROPIC_BASE_URL="https://api.example.com"
```

## 💡 使用技巧

1. **首次使用**：运行 `claude auth login` 登录账号
2. **项目初始化**：在项目根目录创建 `.claude/CLAUDE.md` 说明架构
3. **记忆管理**：Claude 会自动记住重要信息到 `~/.claude/memory/`
4. **权限控制**：在 `settings.json` 中配置自动允许的操作
