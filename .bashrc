# Stop here when this file is sourced by a non-interactive shell.
[[ $- != *i* ]] && return

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '

shopt -s checkwinsize
shopt -s no_empty_cmd_completion
shopt -s histappend
shopt -s globstar

# Keep commands written by concurrent interactive shells in sync.
_bash_capture_status() {
	_bash_prompt_status=$?
}

_bash_prompt_status_segment() {
	((_bash_prompt_status == 0)) || printf ' [%d]' "$_bash_prompt_status"
}

_bash_history_sync() {
	builtin history -a
	builtin history -n
}
if [[ " ${PROMPT_COMMAND[*]-} " != *' _bash_capture_status '* ]]; then
	PROMPT_COMMAND=(_bash_capture_status "${PROMPT_COMMAND[@]}")
fi
if [[ " ${PROMPT_COMMAND[*]-} " != *' _bash_history_sync '* ]]; then
	PROMPT_COMMAND+=(_bash_history_sync)
fi

use_color=false
if [[ $TERM != dumb && -t 1 ]] && command -v dircolors >/dev/null; then
	if [[ -f $HOME/.dir_colors ]]; then
		eval "$(dircolors -b "$HOME/.dir_colors")"
	elif [[ -f /etc/DIR_COLORS ]]; then
		eval "$(dircolors -b /etc/DIR_COLORS)"
	else
		eval "$(dircolors -b)"
	fi
	[[ -n ${LS_COLORS:-} ]] && use_color=true
fi

if [[ -r /usr/share/git/git-prompt.sh ]]; then
	source /usr/share/git/git-prompt.sh
elif [[ -r /usr/share/git/completion/git-prompt.sh ]]; then
	source /usr/share/git/completion/git-prompt.sh
fi

if $use_color; then
	if ((EUID == 0)); then
		PS1='\[\033[01;31m\]\h\[\033[01;34m\] \w$(_bash_prompt_status_segment) \$\[\033[00m\] '
	else
		PS1='\[\033[38;2;166;227;161m\]\u@\h\[\033[0m\]:\[\033[38;2;137;180;250m\]\w\[\033[0m\]\[\033[38;2;245;194;231m\]$(__git_ps1 " (%s)")\[\033[0m\]$(_bash_prompt_status_segment)\[\033[38;2;205;214;244m\]\$\[\033[0m\] '
	fi
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
else
	PS1='\u@\h \w$(__git_ps1 " (%s)")$(_bash_prompt_status_segment) \$ '
fi

if ! shopt -oq posix && ! declare -F _init_completion >/dev/null; then
	if [[ -r /usr/share/bash-completion/bash_completion ]]; then
		source /usr/share/bash-completion/bash_completion
	elif [[ -r /etc/bash_completion ]]; then
		source /etc/bash_completion
	fi
fi

[[ -r $HOME/.config/bash/functions ]] && source "$HOME/.config/bash/functions"
[[ -r $HOME/.config/bash/aliases ]] && source "$HOME/.config/bash/aliases"

set -o vi

_fzf_history() {
	local selected
	selected=$(HISTTIMEFORMAT= builtin fc -lnr -2147483648 |
		fzf --height=40% --reverse --scheme=history --query="$READLINE_LINE") || return
	selected=${selected#"${selected%%[![:space:]]*}"}
	READLINE_LINE=$selected
	READLINE_POINT=${#READLINE_LINE}
}

bind -m vi-command -x '"\C-r": _fzf_history'
bind -m vi-insert -x '"\C-r": _fzf_history'
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[6 q\2'
bind 'set vi-cmd-mode-string \1\e[2 q\2'
bind -m vi-insert '"\e[A": history-search-backward'
bind -m vi-insert '"\e[B": history-search-forward'
bind -m vi-command '"\e[A": history-search-backward'
bind -m vi-command '"\e[B": history-search-forward'

unset use_color
