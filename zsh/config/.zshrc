# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git zsh-syntax-highlighting autojump zsh-autosuggestions)

# Autojump
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Powerlevel10k mode
POWERLEVEL9K_MODE='nerdfont-complete'

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-autosuggestions 颜色
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

### POWERLEVEL9K 配置 ###
POWERLEVEL9K_OS_ICON_BACKGROUND='black'
POWERLEVEL9K_CONTEXT_TEMPLATE='%n'
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='black'
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='white'
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='\u256D\u2500'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{014}\u2570%F{cyan}>%F{073}>%F{101}>%f "
POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='yellow'
POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time ip background_jobs)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
POWERLEVEL9K_TIME_BACKGROUND='white'
POWERLEVEL9K_HOME_ICON=''
POWERLEVEL9K_HOME_SUB_ICON=''
POWERLEVEL9K_FOLDER_ICON=''
POWERLEVEL9K_STATUS_VERBOSE=true
POWERLEVEL9K_STATUS_CROSS=true
#### POWERLEVEL9K END ####

# PATH
export PATH="$HOME/.local/bin:$PATH"

# 加载环境变量
[ -f ~/.env ] && source ~/.env

# Ghostty 环境配置
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  export TERM=xterm-256color
  export COLORTERM=truecolor
  export COLUMNS=$(tput cols 2>/dev/null || echo 120)
fi

# Claude Code 函数
function claude() {
  unset ANTHROPIC_API_KEY
  $HOME/.local/bin/claude "$@"
}

# Claude-Mem 快捷别名
alias cm-worker='$HOME/.local/bin/cm-worker'
alias cm-health='cm-worker health'
alias cm-status='cm-worker status'
alias cm-stats='cm-worker stats'
alias cm-queue='cm-worker queue'
alias cm-viewer='cm-worker viewer'
alias cm-start='cm-worker start'
alias cm-stop='cm-worker stop'
alias cm-restart='cm-worker restart'
alias cm-logs='cm-worker logs'

# Yazi shell wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Zoxide（智能目录跳转）
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"

# 默认编辑器
export EDITOR=vim

# Kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
