# Mac 新机器快速配置指南

本目录包含 Mac 新机器的完整开发环境配置，所有工具均提供一键安装脚本。

## 📦 包含工具

| 工具 | 说明 | 配置目录 |
|------|------|----------|
| **Claude Code** | Anthropic 官方 CLI，AI 编程助手 | [claude-code/](claude-code/) |
| **claude-mem** | Claude 持久化记忆系统（MCP 插件） | [claude-mem/](claude-mem/) |
| **zsh** | Shell 环境（含主题、插件、配色） | [zsh/](zsh/) |
| **ghostty** | 现代终端模拟器（含 yazi、lazygit） | [ghostty/](ghostty/) |

## 🚀 快速开始

### 方式一：全量安装（推荐）
```bash
cd 新机器配置
./install-all.sh
```

### 方式二：单独安装
```bash
# 安装 Claude Code
cd claude-code && ./install.sh

# 安装 claude-mem
cd claude-mem && ./install.sh

# 安装 zsh 环境
cd zsh && ./install.sh

# 安装 ghostty
cd ghostty && ./install.sh
```

## 📝 注意事项

1. **依赖检查**：脚本会自动检测并安装必要依赖（Homebrew、Git 等）
2. **备份提示**：安装前会自动备份现有配置到 `~/.config-backup-YYYYMMDD`

## 🔧 配置说明

每个工具目录包含：
- `install.sh` - 一键配置脚本
- `README.md` - 使用文档和快捷键
- `config/` - 配置文件模板
