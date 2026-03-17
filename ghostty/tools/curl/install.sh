#!/bin/bash
if command -v curl &> /dev/null; then
    echo "✓ curl already installed: $(curl --version | head -1)"
    exit 0
fi
brew install curl
