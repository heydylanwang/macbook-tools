# ghostty 配置指南

ghostty 是现代高性能终端模拟器，支持 GPU 加速和原生 macOS 集成。

## 📦 安装

```bash
./install.sh
```

## 🎯 功能特性

- **GPU 加速渲染**：流畅的滚动和动画
- **原生 macOS 集成**：毛玻璃效果、触控板手势
- **快速终端**：Quake 风格下拉终端（`Ctrl + ~`）
- **分屏支持**：水平/垂直分割
- **Shell 集成**：自动检测命令执行状态

## ⌨️ 快捷键

### 标签页管理
- `Cmd + T` - 新建标签页
- `Cmd + W` - 关闭标签页
- `Cmd + Shift + ←/→` - 切换标签页

### 分屏管理
- `Cmd + D` - 右侧分屏
- `Cmd + Shift + D` - 下方分屏
- `Cmd + Alt + ←/→/↑/↓` - 切换分屏焦点
- `Cmd + Shift + E` - 均分所有分屏
- `Cmd + Shift + F` - 最大化当前分屏

### 字体大小
- `Cmd + +` - 增大字体
- `Cmd + -` - 减小字体
- `Cmd + 0` - 重置字体大小

### 快速终端
- `Ctrl + ~` (全局) - 显示/隐藏快速终端

### 其他
- `Cmd + Shift + ,` - 重载配置

## 🎨 主题配置

当前使用 **Catppuccin Mocha** 主题，支持自动切换明暗模式。

### 毛玻璃效果
```
background-opacity = 0.85
background-blur-radius = 30
```

### 字体配置
```
font-family = "Maple Mono NF CN"
font-size = 14
```

## 🔧 配置文件

位置：`~/.config/ghostty/config`

查看所有选项：
```bash
ghostty +show-config --default --docs
```

## 💡 集成工具

### yazi - 文件管理器
```bash
y              # 启动 yazi
```

### lazygit - Git 管理
```bash
lazygit        # 启动 lazygit
```

详见各工具的独立文档。
