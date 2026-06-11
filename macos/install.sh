#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🍎 开始配置 macOS 系统偏好..."
bash "$SCRIPT_DIR/defaults.sh"
