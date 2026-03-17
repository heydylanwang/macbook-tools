# Homebrew 使用指南

Homebrew 是 macOS 的包管理器。

## 📦 安装

```bash
./install.sh
```

## ⌨️ 常用命令

```bash
# 搜索软件
brew search <名称>

# 安装软件
brew install <软件名>
brew install --cask <应用名>  # GUI 应用

# 卸载软件
brew uninstall <软件名>

# 更新 Homebrew
brew update

# 升级所有软件
brew upgrade

# 查看已安装
brew list

# 查看软件信息
brew info <软件名>

# 清理旧版本
brew cleanup
```

## 💡 使用技巧

- `brew install` - CLI 工具
- `brew install --cask` - GUI 应用
- 定期运行 `brew update && brew upgrade` 更新软件
