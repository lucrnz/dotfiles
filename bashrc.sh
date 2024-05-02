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
# node (local npm packages)
if [ "$(which npm)" == "/usr/bin/npm" ] || [ "$(which npm)" == "/usr/sbin/npm" ]; then
	export NPM_CONFIG_PREFIX="$HOME/.npm/packages"
	test -d "$NPM_CONFIG_PREFIX/bin" || mkdir -p "$NPM_CONFIG_PREFIX/bin"
	prepend_path "$NPM_CONFIG_PREFIX/bin"
	export NODE_PATH=$NPM_CONFIG_PREFIX/lib/node_modules:$NODE_PATH
fi

# pnpm
if test -d "$HOME/.local/share/pnpm"; then
	export PNPM_HOME="$HOME/.local/share/pnpm"
	case ":$PATH:" in
	  *":$PNPM_HOME:"*) ;;
	  *) export PATH="$PNPM_HOME:$PATH" ;;
	esac
fi
# pnpm end

# bun
if test -d "$HOME/.bun"; then
	export BUN_INSTALL="$HOME/.bun"
	prepend_path "$BUN_INSTALL/bin"
fi

# go
if test -d "$HOME/.local/share/go"; then
	export GOROOT="$HOME/.local/share/go"
	export GOPATH="$HOME/go"
	prepend_path "$GOROOT/bin"
	prepend_path "$GOPATH/bin"
# ---------------------------------------
alias ls='ls -l --color=auto'
# ---------------------------------------
test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" &&
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"

