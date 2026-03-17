#!/bin/bash
set -e

echo "🚀 开始安装终端基础工具..."
echo ""

# 1. Homebrew（最优先）
echo "📦 [1/4] 安装 Homebrew..."
cd brew && ./install.sh && cd ..

# 2. Python
echo ""
echo "📦 [2/4] 安装 Python3..."
cd python && ./install.sh && cd ..

# 3. GitHub CLI
echo ""
echo "📦 [3/4] 安装 GitHub CLI..."
cd gh && ./install.sh && cd ..

# 4. Vim
echo ""
echo "📦 [4/4] 安装 Vim..."
cd vim && ./install.sh && cd ..

echo ""
echo "✅ 终端基础工具安装完成！"
echo ""
echo "📌 已安装："
echo "  ✓ Homebrew - 包管理器"
echo "  ✓ Python3 & pip3 - Python 环境"
echo "  ✓ gh - GitHub CLI"
echo "  ✓ Vim - 文本编辑器"
