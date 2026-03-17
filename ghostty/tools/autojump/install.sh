#!/bin/bash
if command -v autojump &> /dev/null; then
    echo "✓ autojump already installed"
    exit 0
fi
brew install autojump
echo "Add to ~/.zshrc: [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh"
