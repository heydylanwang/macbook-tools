#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v autojump &> /dev/null; then
    echo "✓ autojump already installed"
    exit 0
fi
brew install autojump
echo "Add to ~/.zshrc: [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh"
