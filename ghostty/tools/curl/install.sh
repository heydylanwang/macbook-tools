#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v curl &> /dev/null; then
    echo "✓ curl already installed: $(curl --version | head -1)"
    exit 0
fi
brew install curl
