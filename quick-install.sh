#!/bin/bash
# 禁用 zsh 配置加载，加速启动
export ZDOTDIR=/tmp
exec bash "$(dirname "$0")/install-all.sh"
