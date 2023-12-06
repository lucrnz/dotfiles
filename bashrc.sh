#!/usr/bin/env bash
[[ $- != *i* ]] && return
# ---------------------------------------
export PS1='\[\e[38;5;205m\]\h\[\e[0m\]:\[\e[38;5;105m\]\W\[\e[0m\]\\$ '
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
if [ "$(which npm)" == "/usr/bin/npm" ] || [ "$(which npm)" == "/usr/sbin/npm" ]; then
	export NPM_CONFIG_PREFIX="$HOME/.npm/packages"
	test -d "$NPM_CONFIG_PREFIX/bin" || mkdir -p "$NPM_CONFIG_PREFIX/bin"
	prepend_path "$NPM_CONFIG_PREFIX/bin"
	export NODE_PATH=$NPM_CONFIG_PREFIX/lib/node_modules:$NODE_PATH
fi
if [ "$TERM_PROGRAM" != "vscode" ]; then
	cmd_exists "nix" && cmd_exists "direnv" && eval "$(direnv hook bash)"
fi
if [ -d "$HOME/.local/share/cli-apps" ]; then
    for f in "$HOME/.local/share/cli-apps/"*.sh; do
        source "$f"
    done
fi
# ---------------------------------------
alias ls='ls -l --color=auto'
cmd_exists ffplay && alias ffplay_audio='ffplay -autoexit -nodisp'
cmd_exists doas && alias sudo='doas'
# ---------------------------------------
test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" &&
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"
