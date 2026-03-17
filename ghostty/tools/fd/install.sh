#!/bin/bash
if command -v fd &> /dev/null; then
    echo "✓ fd already installed: $(fd --version)"
    exit 0
fi
brew install fd
