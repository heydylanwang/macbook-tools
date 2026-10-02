#!/usr/bin/env bash
# sync-to-usb.sh · 把本仓最新状态 (含 .git) 镜像到移动硬盘, 新机免 clone
#
# 用法:
#   ./sync-to-usb.sh                 镜像到默认盘 /Volumes/Sandisk-Public/macbook-tools
#   ./sync-to-usb.sh <目标目录>       镜像到指定目录
#   ./sync-to-usb.sh --dry-run        只打印将同步什么
#
# 需在本地仓内运行 (SCRIPT_DIR 即同步源)。--delete 使硬盘完全镜像本仓。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0; USB="/Volumes/Sandisk-Public/macbook-tools"
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) USB="$a" ;;
  esac
done

# 源在硬盘上则拒绝 (避免自己同步自己)
case "$SCRIPT_DIR" in
  /Volumes/*) echo "✗ 请在本地仓内运行, 当前在硬盘: $SCRIPT_DIR" >&2; exit 1 ;;
esac

# 提醒未提交 / 未推送 (保证硬盘副本 = github)
if [ -n "$(git -C "$SCRIPT_DIR" status --porcelain 2>/dev/null)" ]; then
  printf '\033[33m!\033[0m 有未提交改动, 硬盘副本将包含未提交内容 (建议先 commit)\n'
fi
AHEAD="$(git -C "$SCRIPT_DIR" rev-list --count '@{u}..HEAD' 2>/dev/null || echo '?')"
[ "$AHEAD" != "0" ] && [ "$AHEAD" != "?" ] && printf '\033[33m!\033[0m 本地领先远端 %s 个 commit 未 push (建议先 push)\n' "$AHEAD"

# 目标父目录需存在 (外接盘挂载)
PARENT="$(dirname "$USB")"
[ -d "$PARENT" ] || { echo "✗ 目标盘未挂载: $PARENT" >&2; exit 1; }

echo "同步: $SCRIPT_DIR/  ->  $USB/"
if [ "$DRY" = 1 ]; then
  rsync -an --delete --exclude='.DS_Store' "$SCRIPT_DIR/" "$USB/" | tail -20
  echo "(dry-run, 未落地)"
else
  mkdir -p "$USB"
  rsync -a --delete --exclude='.DS_Store' "$SCRIPT_DIR/" "$USB/"
  tip="$(git -C "$USB" log -1 --format='%h %s' 2>/dev/null || echo '?')"
  echo "✅ 完成。硬盘副本 tip: $tip"
fi
