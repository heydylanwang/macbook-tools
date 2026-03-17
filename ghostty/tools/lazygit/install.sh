#!/bin/bash
if command -v lazygit &> /dev/null; then
    echo "✓ lazygit already installed: $(lazygit --version)"
    exit 0
fi
brew install lazygit
