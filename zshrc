# shell settings
setopt histignorealldups sharehistory

HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

autoload -Uz compinit
compinit

# load suggestions from common directories
_sourcefile="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -f "$_sourcefile" && source "$_sourcefile"
unset _sourcefile

_sourcefile="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -f "$_sourcefile" && source "$_sourcefile"
unset _sourcefile

## load suggestions from home directory
_sourcefile="$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
test -f "$_sourcefile" && source "$_sourcefile"
unset _sourcefile

_sourcefile="$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
test -f "$_sourcefile" && source "$_sourcefile"
unset _sourcefile


# function definitions
# ---------------------------------------
cmd_exists() { command -v $1 &>/dev/null; }
prepend_path() { test -d "$@" && export PATH="$@:$PATH"; }
fork_muted() { $@ >/dev/null 2>&1 & }
alias _fm="fork_muted"
# ---------------------------------------
prepend_path "/snap/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.conf_files/scripts"
prepend_path "$HOME/.dotnet/tools"
prepend_path "$HOME/.local/share/flutter_sdk"
# ---------------------------------------
if cmd_exists starship; then
	eval "$(starship init zsh)"
else
	export PS1='\[\e[38;5;205m\]\h\[\e[0m\]:\[\e[38;5;105m\]\W\[\e[0m\]\\$ '
fi
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
# homebrew setup
if ! cmd_exists brew; then
	if test -d "/opt/homebrew"; then
		# macOS
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif test -d "/home/linuxbrew/.linuxbrew"; then
		# Linux
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
	fi
fi

_brew_provides() {
    local bin
    bin=$(command -v "$1" 2>/dev/null) || return 1
    case "$bin" in
        *"/homebrew/"* | *"/linuxbrew/"*) return 0 ;;
        *) return 1 ;;
    esac
}
# ----------------------------------------
# node
if ! _brew_provides node; then
	# try to use nvm
	if [ -f "$HOME/.nvm/nvm.sh" ]; then
		export NVM_DIR="$HOME/.nvm"
		\. "$NVM_DIR/nvm.sh"
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
	else
		if cmd_exists "node" && cmd_exists "npm"; then
			# if not, try to use the system node with a workaround for having local npm packages on the home directory.
			if [[ "$(which npm)" == "/usr/bin/npm" || "$(which npm)" == "/usr/sbin/npm" ]]; then
				export NPM_CONFIG_PREFIX="$HOME/.npm/packages"
				test -d "$NPM_CONFIG_PREFIX/bin" || mkdir -p "$NPM_CONFIG_PREFIX/bin"
				prepend_path "$NPM_CONFIG_PREFIX/bin"
				export NODE_PATH="$NPM_CONFIG_PREFIX/lib/node_modules:$NODE_PATH"
			fi
		fi
	fi
fi
# ----------------------------------------
# pnpm
if ! _brew_provides pnpm && test -d "$HOME/.local/share/pnpm"; then
	export PNPM_HOME="$HOME/.local/share/pnpm"
	case ":$PATH:" in
	  *":$PNPM_HOME:"*) ;;
	  *) export PATH="$PNPM_HOME:$PATH" ;;
	esac
fi
# ------------------------------------------
# bun
if ! _brew_provides bun && test -d "$HOME/.bun"; then
	export BUN_INSTALL="$HOME/.bun"
	prepend_path "$BUN_INSTALL/bin"
	[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
fi
# -----------------------------------------
# go
if ! _brew_provides go && test -d "$HOME/.local/share/go"; then
	export GOROOT="$HOME/.local/share/go"
	export GOPATH="$HOME/go"
	prepend_path "$GOROOT/bin"
	prepend_path "$GOPATH/bin"
fi
# -----------------------------------------
# podman
if cmd_exists podman && cmd_exists docker-compose; then
	export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
fi
# ----------------------------------------

# Load Angular CLI autocompletion.
cmd_exists ng && source <(ng completion script)

# ---------------------------------------
alias ls='ls -l --color=auto'

# Host quirks
_sourcefile="$HOME/.conf_files/host_quirks/$HOSTNAME.sh"
[[ -f "$_sourcefile" ]] && source "$_sourcefile"
unset _sourcefile
