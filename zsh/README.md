# zsh 配置指南

zsh 是强大的 Shell 环境，配合 Oh My Zsh 和 Powerlevel10k 主题。

## 📦 安装

```bash
./install.sh
```

## 🎯 包含组件

- **Oh My Zsh** - zsh 配置框架
- **Powerlevel10k** - 高性能主题
- **插件**：
  - `git` - Git 快捷命令
  - `zsh-syntax-highlighting` - 语法高亮
  - `zsh-autosuggestions` - 命令建议
  - `autojump` - 智能目录跳转

## ⌨️ 常用快捷键

### 命令编辑
- `Ctrl + A` - 跳到行首
- `Ctrl + E` - 跳到行尾
- `Ctrl + U` - 删除到行首
- `Ctrl + K` - 删除到行尾
- `Ctrl + W` - 删除前一个单词
- `Ctrl + R` - 历史命令搜索

### 自动建议
- `→` (右箭头) - 接受建议
- `Ctrl + →` - 接受一个单词

### 目录跳转
```bash
j <关键词>    # autojump 智能跳转
z <关键词>    # zoxide 智能跳转（需单独安装）
```

## 🎨 主题配置

### Powerlevel10k 元素
- `os_icon` - 系统图标
- `context` - 用户名
- `dir` - 当前目录
- `vcs` - Git 状态
- `time` - 时间
- `ip` - IP 地址
- `background_jobs` - 后台任务

### 自定义提示符
编辑 `~/.zshrc` 中的 `POWERLEVEL9K_*` 变量。

## 🔧 插件说明

### git 插件别名
```bash
gst    # git status
gaa    # git add --all
gcmsg  # git commit -m
gp     # git push
gl     # git pull
gco    # git checkout
gcb    # git checkout -b
```

### zsh-syntax-highlighting
实时高亮命令：
- 绿色 = 有效命令
- 红色 = 无效命令
- 蓝色 = 路径

### zsh-autosuggestions
根据历史记录自动建议命令，按 `→` 接受。

## 💡 使用技巧

1. **首次配置**：运行 `p10k configure` 自定义主题
2. **重载配置**：`source ~/.zshrc`
3. **查看别名**：`alias` 查看所有别名
4. **历史搜索**：`Ctrl + R` 然后输入关键词
