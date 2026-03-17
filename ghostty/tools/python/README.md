# Python 使用指南

Python 3 开发环境。

## 📦 安装

```bash
./install.sh
```

## ⌨️ 常用命令

```bash
# 查看版本
python3 --version
pip3 --version

# 安装包
pip3 install <包名>

# 卸载包
pip3 uninstall <包名>

# 查看已安装
pip3 list

# 导出依赖
pip3 freeze > requirements.txt

# 安装依赖
pip3 install -r requirements.txt

# 虚拟环境
python3 -m venv venv
source venv/bin/activate
deactivate
```

## 💡 使用技巧

- 使用虚拟环境隔离项目依赖
- 定期更新 pip：`pip3 install --upgrade pip`
