#!/bin/bash
if command -v git &> /dev/null; then
    echo "✓ Git already installed: $(git --version)"
    exit 0
fi
brew install git
