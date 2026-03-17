#!/bin/bash
set -e

# 确保 Homebrew 在 PATH 中
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"

if command -v ffmpeg &> /dev/null; then
    echo "✓ ffmpeg already installed: $(ffmpeg -version | head -1)"
    exit 0
fi
brew install ffmpeg
