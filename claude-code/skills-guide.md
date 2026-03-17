# Claude Code Skills 说明

Skills 是 Claude Code 的可扩展命令系统。

## 📚 已安装 Skills

### /commit - 智能 Git 提交
自动分析代码变更，生成规范的提交信息。

**使用场景**：
- 完成功能开发后快速提交
- 自动遵循项目提交规范
- 包含 Co-Authored-By 标记

**用法**：
```bash
/commit
```

### /simplify - 代码质量审查
审查已修改的代码，检查重复、质量和效率问题。

**使用场景**：
- 代码重构后检查
- 提交前质量把关
- 发现潜在优化点

**用法**：
```bash
/simplify
```

### /loop - 定时执行命令
按固定间隔重复执行命令或提示。

**使用场景**：
- 定期检查部署状态
- 监控构建进度
- 定时运行测试

**用法**：
```bash
/loop 5m /commit     # 每 5 分钟执行一次 commit
/loop 10m "检查部署"  # 每 10 分钟检查部署（默认 10m）
```

### /claude-api - Claude API 开发
辅助开发使用 Claude API 的应用。

**触发条件**：
- 代码导入 `anthropic` 或 `@anthropic-ai/sdk`
- 用户询问 Claude API 使用方法

**用法**：
```bash
/claude-api
```

## 🔧 自定义 Skills

Skills 存储在 `~/.claude/skills/` 目录。

### 创建新 Skill

1. 在 `~/.claude/skills/` 创建 `.md` 文件
2. 添加 frontmatter 配置
3. 编写 Skill 提示内容

**示例**：
```markdown
---
name: review
description: 代码审查
---

请审查当前的代码变更，关注：
1. 代码规范
2. 潜在 bug
3. 性能问题
4. 安全隐患
```

## 💡 使用技巧

1. **查看可用 Skills**：在对话中输入 `/` 查看自动补全
2. **组合使用**：先 `/simplify` 优化代码，再 `/commit` 提交
3. **定时任务**：用 `/loop` 实现自动化工作流
