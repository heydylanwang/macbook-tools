#!/bin/bash
if command -v node &> /dev/null; then
    echo "✓ Node.js already installed: $(node --version)"
    exit 0
fi
brew install node
