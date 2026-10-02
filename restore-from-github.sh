#!/usr/bin/env bash
# restore-from-github.sh · 新机 GitHub 与记忆一键还原 (幂等 可重跑 自校验)
#
# 职责划分:
#   install-all.sh        只装通用开发环境 (brew / 字体 / zsh / 编辑器 / Claude Code CLI)
#   restore-from-github.sh 单独处理个人 GitHub 相关: git 凭据 / clone 仓 /
#                          agent-memory 身份系统 (agent-id 命令 + hooks) / Claude Code 配置与插件 /
#                          可选的本机记忆 (auto-memory) 还原
#
# 身份系统只认 agent-memory, 不再有 planner-memory 软链 (旧迁移产物已彻底移除)。
#
# 前提: 已先跑完 install-all.sh (gh + claude + python3 在场)。
#       settings 模板用户名无关 (占位符 __HOME__ 回填为当前 $HOME), 任意 mac 用户名可用。
#       auto-memory 目录名按原机绝对路径编码, 仅当新机用户名与原机一致时才会被自动加载。
#
# 用法:
#   ./restore-from-github.sh            完整还原 (交互式 gh 登录)
#   ./restore-from-github.sh --dry-run  只打印将做什么, 不落地
#   ./restore-from-github.sh --no-memory   跳过从外接盘还原 auto-memory
#   ./restore-from-github.sh --no-plugins  跳过插件重装
#   ./restore-from-github.sh --memory=<tgz路径>  指定 dotclaude tgz
#   ./restore-from-github.sh --help
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- 配置 ----
GH_ACCOUNT_MAIN="chinese-developer"
AGENT_MEMORY_DIR="$HOME/agent-memory"
AGENT_MEMORY_REPO="https://github.com/chinese-developer/agents-memory.git"

# 待 clone 的代码仓: URL|目标绝对路径 (macbook-tools 自身即脚本所在仓, 不在此列)
REPOS=(
  "https://github.com/chinese-developer/AndroidArchBlueprint.git|$HOME/AndroidStudioProjects/AndroidArchBlueprint"
  "https://github.com/chinese-developer/AtlasSportSDK.git|$HOME/GithubProjects/AtlasSportSDK"
)

# Claude Code 插件市场: marketplace名|owner/repo
MARKETPLACES=(
  "claude-hud|jarrodwatts/claude-hud"
  "claude-plugins-official|anthropics/claude-plugins-official"
  "superpowers-marketplace|obra/superpowers-marketplace"
  "karpathy-skills|forrestchang/andrej-karpathy-skills"
  "understand-anything|Lum1104/Understand-Anything"
  "thedotmack|thedotmack/claude-mem"
)

# 已装插件: plugin@marketplace
PLUGINS=(
  "claude-hud@claude-hud"
  "superpowers@claude-plugins-official"
  "andrej-karpathy-skills@karpathy-skills"
  "swift-lsp@claude-plugins-official"
  "understand-anything@understand-anything"
)

# Claude 配置模板 (用户名无关, __HOME__ 回填为当前 $HOME); 优先脚本旁, 兜底已 clone 的 macbook-tools
TEMPLATE_CANDIDATES=(
  "$SCRIPT_DIR/claude-code"
  "$HOME/GithubProjects/macbook-tools/claude-code"
)

# auto-memory 归档默认位置 (找不到则 glob 最新一份)
MEMORY_TGZ_DEFAULT="/Volumes/Sandisk-Public/work/macbook-backup-*/dotclaude/dotclaude-*.tgz"

# ---- 参数 ----
DRY=0; DO_MEMORY=1; DO_PLUGINS=1; MEMORY_TGZ=""
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --no-memory) DO_MEMORY=0 ;;
    --no-plugins) DO_PLUGINS=0 ;;
    --memory=*) MEMORY_TGZ="${a#*=}" ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "未知参数: $a" >&2; exit 2 ;;
  esac
done

say () { printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn () { printf '  \033[33m!\033[0m %s\n' "$1"; }
head () { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
run () { if [ "$DRY" = 1 ]; then printf '  [dry] %s\n' "$1"; else eval "$1"; fi }

# ---- 前置检查 ----
head "前置检查"
for bin in git gh claude python3; do
  command -v "$bin" >/dev/null 2>&1 && say "$bin 在场" || { echo "  缺 $bin, 请先跑 install-all.sh"; exit 1; }
done

# ---- git 凭据 ----
head "git 凭据 (gh)"
if gh auth status 2>/dev/null | grep -q "account $GH_ACCOUNT_MAIN"; then
  say "gh 已登录 $GH_ACCOUNT_MAIN"
else
  warn "未登录 $GH_ACCOUNT_MAIN, 启动交互登录 (浏览器授权一次)"
  run "gh auth login --hostname github.com --git-protocol https --web"
fi

# ---- clone agent-memory (身份仓, 无软链) ----
head "agent-memory 身份仓"
if [ -d "$AGENT_MEMORY_DIR/.git" ]; then
  say "$AGENT_MEMORY_DIR 已存在, 跳过 clone"
else
  run "git clone '$AGENT_MEMORY_REPO' '$AGENT_MEMORY_DIR'"
fi

# ---- clone 代码仓 ----
head "代码仓"
for entry in "${REPOS[@]}"; do
  url="${entry%%|*}"; dst="${entry##*|}"
  if [ -d "$dst/.git" ]; then
    say "$(basename "$dst") 已存在, 跳过"
  else
    run "mkdir -p '$(dirname "$dst")'"
    run "git clone '$url' '$dst'"
  fi
done

# ---- 写 Claude 配置 (通用模板, 回填 $HOME); bootstrap 之前, 其 merge 需要 settings 已在场 ----
head "Claude 配置 (settings / CLAUDE.md)"
TPL_DIR=""
for cand in "${TEMPLATE_CANDIDATES[@]}"; do
  [ -f "$cand/settings.json.default" ] && { TPL_DIR="$cand"; break; }
done
if [ -n "$TPL_DIR" ]; then
  run "mkdir -p '$HOME/.claude'"
  run "[ -f '$HOME/.claude/settings.json' ] && cp '$HOME/.claude/settings.json' '$HOME/.claude/settings.json.bak' || true"
  run "sed 's#__HOME__#$HOME#g' '$TPL_DIR/settings.json.default' > '$HOME/.claude/settings.json'"
  run "cp '$TPL_DIR/CLAUDE.md.default' '$HOME/.claude/CLAUDE.md'"
  say "settings.json + CLAUDE.md 已写入 (模板源: $TPL_DIR, __HOME__ -> $HOME)"
else
  warn "未找到配置模板, 跳过; bootstrap 将生成最小 settings"
  run "mkdir -p '$HOME/.claude'"
  run "[ -f '$HOME/.claude/settings.json' ] || echo '{}' > '$HOME/.claude/settings.json'"
fi

# ---- 从外接盘还原 auto-memory (projects) ----
if [ "$DO_MEMORY" = 1 ]; then
  head "本机记忆 (auto-memory)"
  if [ -z "$MEMORY_TGZ" ]; then
    shopt -s nullglob
    _cands=( $MEMORY_TGZ_DEFAULT )
    shopt -u nullglob
    _n=${#_cands[@]}
    [ "$_n" -gt 0 ] && MEMORY_TGZ="${_cands[$((_n-1))]}"
  fi
  if [ -n "$MEMORY_TGZ" ] && [ -f "$MEMORY_TGZ" ]; then
    run "mkdir -p '$HOME/.claude'"
    # 只还原 projects (auto-memory + 会话历史), 不覆盖 settings/commands/hooks
    run "tar -xzf '$MEMORY_TGZ' -C '$HOME/.claude' ./projects 2>/dev/null || true"
    say "已从 $MEMORY_TGZ 还原 auto-memory"
  else
    warn "未找到 dotclaude tgz (外接盘未挂载?), 跳过 auto-memory"
  fi
fi

# ---- agent-memory bootstrap: 重建 agent-id/resume 命令 + hooks + settings 合并 + git-hooks ----
head "agent-memory bootstrap"
if [ "$DRY" = 1 ]; then
  run "bash '$AGENT_MEMORY_DIR/install/bootstrap.sh' --dry-run"
else
  bash "$AGENT_MEMORY_DIR/install/bootstrap.sh" --yes
fi

# ---- Claude Code 插件重装 ----
if [ "$DO_PLUGINS" = 1 ]; then
  head "Claude Code 插件"
  for mk in "${MARKETPLACES[@]}"; do
    name="${mk%%|*}"; repo="${mk##*|}"
    run "claude plugin marketplace add '$repo' 2>/dev/null || true"
    say "marketplace $name ($repo)"
  done
  for p in "${PLUGINS[@]}"; do
    run "claude plugin install '$p' 2>/dev/null || true"
    say "plugin $p"
  done
fi

# ---- 自校验 ----
head "自校验"
if [ "$DRY" = 1 ]; then
  printf '\n== dry-run 结束, 未改任何文件 ==\n'; exit 0
fi
FAIL=0
[ -L "$HOME/.claude/commands/agent-id.md" ] && say "agent-id 命令软链在场" || { echo "  缺 agent-id 命令"; FAIL=1; }
python3 "$AGENT_MEMORY_DIR/install/lib/registry.py" planner >/dev/null 2>&1 && say "registry.py 解析 OK" || { echo "  registry.py FAIL"; FAIL=1; }
[ -e "$HOME/planner-memory" ] && warn "检测到残留 ~/planner-memory (本方案已不需要, 可 rm 掉)" || say "无 planner-memory 残留"
for entry in "${REPOS[@]}"; do dst="${entry##*|}"; [ -d "$dst/.git" ] && say "$(basename "$dst") clone OK" || { echo "  缺 $dst"; FAIL=1; }; done
[ -d "$AGENT_MEMORY_DIR/.git" ] && say "agent-memory clone OK" || { echo "  缺 agent-memory"; FAIL=1; }
python3 -c "import json;d=json.load(open('$HOME/.claude/settings.json'));assert 'inject-shared-rules.sh' in json.dumps(d.get('hooks',{}))" 2>/dev/null \
  && say "settings hooks 已注册" || { echo "  settings hooks 缺失"; FAIL=1; }

head "完成"
if [ "$FAIL" = 0 ]; then
  echo "✅ 还原完成。下一步: 重启终端, 在任一仓内跑 'claude' 后用 /agent-id 验证身份系统。"
else
  echo "⚠️ 存在未通过项 (见上), 请按提示修复后重跑 (脚本幂等)。"
  exit 1
fi
