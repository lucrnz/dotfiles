#!/usr/bin/env bash
[[ $- != *i* ]] && return
# ---------------------------------------
export PS1="\[\033[38;5;7m\][\A]\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;78m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;69m\]\h\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;7m\]>\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;141m\]\w\[$(tput sgr0)\]\n\\$ \[$(tput sgr0)\]"
# ---------------------------------------
cmd_exists() { command -v $1 &>/dev/null; }
prepend_path() { test -d "$@" && export PATH="$@:$PATH"; }
fork_muted() { $@ >/dev/null 2>&1 & }
alias _fm="fork_muted"
# ---------------------------------------
prepend_path "/snap/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.conf_files/scripts"
prepend_path "$HOME/.config/composer/vendor/bin"
# ---------------------------------------
if cmd_exists dpkg; then
	apt_autopurge() {
		sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
	}
fi
# ---------------------------------------
cmd_exists "nano" && export EDITOR=nano
cmd_exists "vim" && export EDITOR=vim
cmd_exists "nvim" && export EDITOR=nvim
# ---------------------------------------
# if [ "$(which npm)" == "/usr/bin/npm" ] || [ "$(which npm)" == "/usr/sbin/npm" ]; then
# 	export NPM_CONFIG_PREFIX="$HOME/.npm/packages"
# 	test -d "$NPM_CONFIG_PREFIX/bin" || mkdir -p "$NPM_CONFIG_PREFIX/bin"
# 	prepend_path "$NPM_CONFIG_PREFIX/bin"
# 	export NODE_PATH=$NPM_CONFIG_PREFIX/lib/node_modules:$NODE_PATH
# fi
if [ "$TERM_PROGRAM" != "vscode" ]; then
	cmd_exists "nix" && cmd_exists "direnv" && eval "$(direnv hook bash)"
fi
# ---------------------------------------
alias ls='ls -l --color=auto'
cmd_exists ffplay && alias ffplay_audio='ffplay -autoexit -nodisp'
cmd_exists doas && alias sudo='doas'
# ---------------------------------------
test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" &&
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"
