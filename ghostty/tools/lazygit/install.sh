#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v lazygit &> /dev/null; then
    echo "✓ lazygit already installed: $(lazygit --version)"
    exit 0
fi
brew install lazygit
