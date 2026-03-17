#!/bin/bash
if command -v ffmpeg &> /dev/null; then
    echo "✓ ffmpeg already installed: $(ffmpeg -version | head -1)"
    exit 0
fi
brew install ffmpeg
