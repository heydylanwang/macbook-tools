#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v yazi &> /dev/null; then
    echo "✓ yazi already installed: $(yazi --version)"
    exit 0
fi
brew install yazi ffmpegthumbnailer sevenzip jq poppler fd ripgrep fzf zoxide imagemagick
echo ""
echo "⚠️  需要手动配置 Shell wrapper："
echo "添加到 ~/.zshrc 或 ~/.bashrc："
echo 'function y() {'
echo '    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd'
echo '    yazi "$@" --cwd-file="$tmp"'
echo '    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then'
echo '        builtin cd -- "$cwd"'
echo '    fi'
echo '    rm -f -- "$tmp"'
echo '}'
