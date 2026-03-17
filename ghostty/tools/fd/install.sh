#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v fd &> /dev/null; then
    echo "✓ fd already installed: $(fd --version)"
    exit 0
fi
brew install fd
