# lazygit 使用指南

lazygit 是终端下的 Git 可视化管理工具。

## 🚀 启动

```bash
lazygit        # 在当前 Git 仓库启动
```

## ⌨️ 快捷键

### 面板切换
- `1` - Status（状态）
- `2` - Files（文件）
- `3` - Branches（分支）
- `4` - Commits（提交）
- `5` - Stash（暂存）

### 文件操作
- `Space` - Stage/Unstage 文件
- `a` - Stage/Unstage 所有文件
- `c` - 提交（Commit）
- `A` - 修改上次提交（Amend）
- `d` - 查看差异（Diff）
- `e` - 编辑文件
- `o` - 打开文件
- `i` - 忽略文件

### 分支操作
- `n` - 新建分支
- `Space` - 切换分支
- `m` - 合并分支
- `r` - 变基（Rebase）
- `d` - 删除分支
- `P` - Push
- `p` - Pull

### 提交操作
- `Enter` - 查看提交详情
- `s` - Squash（压缩提交）
- `r` - Reword（修改提交信息）
- `d` - 删除提交
- `g` - Reset 到此提交

### 其他
- `?` - 查看帮助
- `x` - 打开命令菜单
- `q` - 退出当前面板
- `Ctrl + c` - 退出 lazygit

## 🎨 界面说明

- **左侧面板**：文件列表/分支列表/提交列表
- **右侧面板**：差异预览/提交详情
- **底部**：操作提示和快捷键

## 💡 使用技巧

1. **快速提交**：在 Files 面板按 `Space` 选择文件，按 `c` 提交
2. **交互式变基**：在 Commits 面板选择提交，按 `e` 编辑
3. **解决冲突**：在 Files 面板选择冲突文件，按 `Space` 标记已解决
4. **查看历史**：切换到 Commits 面板，按 `Enter` 查看详情
