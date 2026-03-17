# GitHub CLI 使用指南

gh 是 GitHub 官方命令行工具。

## 📦 安装

```bash
./install.sh
```

## ⌨️ 常用命令

```bash
# 登录
gh auth login

# 仓库操作
gh repo clone <仓库>
gh repo create <名称>
gh repo view

# PR 操作
gh pr create
gh pr list
gh pr view <编号>
gh pr checkout <编号>
gh pr merge <编号>

# Issue 操作
gh issue create
gh issue list
gh issue view <编号>
gh issue close <编号>

# 查看运行状态
gh run list
gh run view <ID>
```

## 💡 使用技巧

- 首次使用运行 `gh auth login` 登录
- `gh pr create` 快速创建 PR
- `gh repo view -w` 在浏览器打开仓库
