#!/usr/bin/env bash
[[ $- != *i* ]] && return
# ---------------------------------------
export PS1="\[\033[38;5;7m\][\A]\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;78m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;69m\]\h\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;7m\]>\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;141m\]\w\[$(tput sgr0)\]\n\\$ \[$(tput sgr0)\]"
# ---------------------------------------
cmd_exists() { command -v $1 &>/dev/null ; }
prepend_path() { test -d "$@" && export PATH="$@:$PATH"; }
fork_muted() { $@ >/dev/null 2>&1& }
alias _fm="fork_muted"
# ---------------------------------------
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.conf_files/scripts"
prepend_path "$HOME/.local/share/go/bin"
prepend_path "$HOME/.local/share/nimble/bin"
prepend_path "/snap/bin"
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
# dotnet - https://dotnet.microsoft.com/en-us/download/dotnet/7.0
if test -d "$HOME/.local/share/dotnet"; then
  export PATH="$HOME/.local/share/dotnet:$PATH"
  export DOTNET_ROOT="$HOME/.local/share/dotnet"
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi
# ---------------------------------------
# Deno version manager & Deno packages
# curl -fsSL https://dvm.deno.dev | sh
if test -d "$HOME/.dvm"; then
	export DVM_DIR="$HOME/.dvm"
	export PATH="$DVM_DIR/bin:$PATH"

	if test -d "$HOME/.deno/bin"; then
		export PATH="$HOME/.deno/bin:$PATH"
	fi
fi
# ---------------------------------------
[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env
# ---------------------------------------
# Go programming language - https://go.dev/dl/
# mkdir -p "$HOME/.local/share"; curl -L https://go.dev/dl/go1.19.5.linux-amd64.tar.gz | tar -C "$HOME/.local/share" -xf -
test -d "$HOME/.local/share/go" && export GOROOT=$HOME/.local/share/go
test -d "$HOME/go" && export GOPATH="$HOME/go"
test -d "$HOME/go/bin" && prepend_path "$HOME/go/bin"
# ---------------------------------------
# Nim programming language - https://nim-lang.org/install_unix.html
# curl https://nim-lang.org/choosenim/init.sh -sSf | sh
if test -d "$HOME/.nimble/bin"; then
	export PATH="$PATH:$HOME/.nimble/bin"
fi
# ---------------------------------------
# Node version manager - https://github.com/nvm-sh/nvm#installing-and-updating
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
# mv $HOME/.nvm $HOME/.local/share/nvm
# nvm install node
# nvm use node

if test -d "$HOME/.local/share/nvm"; then
  export NVM_DIR="$HOME/.local/share/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi
# ---------------------------------------
alias ls='ls -l --color=auto'
alias irssi='irssi -n lucie-cupcakes --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'
cmd_exists ffplay && alias ffplay_audio='ffplay -autoexit -nodisp'
# ---------------------------------------
# pnpm package manager - https://pnpm.io/
# curl -fsSL https://get.pnpm.io/install.sh | sh -
if test -d "$HOME/.local/share/pnpm"; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi
# ---------------------------------------
# Rust programming language
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
test -f "$HOME/.cargo/env" && . "$HOME/.cargo/env"
# ---------------------------------------
test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" && \
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"
