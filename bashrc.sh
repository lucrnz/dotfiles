#!/bin/bash
# LUCIE'S BASHRC
# DONT TOUCH IT OR YOU WILL DIE
#      ,;;*;;;;,
#     .-'``;-');;.
#    /'  .-.  /*;;
#  .'    \d    \;;               .;;;,
# / o      `    \;    ,__.     ,;*;;;*;,
# \__, _.__,'   \_.-') __)--.;;;;;*;;;;,
#  `""`;;;\       /-')_) __)  `\' ';;;;;;
#     ;*;;;        -') `)_)  |\ |  ;;;;*;
#     ;;;;|        `---`    O | | ;;*;;;
#     *;*;\|                 O  / ;;;;;*
#    ;;;;;/|    .-------\      / ;*;;;;;
#   ;;;*;/ \    |        '.   (`. ;;;*;;;
#   ;;;;;'. ;   |          )   \ | ;;;;;;
#   ,;*;;;;\/   |.        /   /` | ';;;*;
#    ;;;;;;/    |/       /   /__/   ';;;
#    '"*"'/     |       /    |      ;*;
#         `""""`        `""""`     ;'
[[ $- != *i* ]] && return

cmd_exists() { command -v $1 &>/dev/null ; }
prepend_path() { test -d "$@" && export PATH="$@:$PATH"; }

export PS1="\[\033[38;5;225m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;189m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]\n% \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\$ '

prepend_path "/usr/bin/watcom/binl"
prepend_path "/usr/local/go/bin"
prepend_path "/snap/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.local/share/go/bin"
prepend_path "$HOME/.local/share/nimble/bin"
prepend_path "$HOME/.local/share/pyston"

test -f "$HOME/.cargo/env" && source "$HOME/.cargo/env"
if test -d "$HOME/.local/share/dotnet"; then
	export PATH="$HOME/.local/share/dotnet:$PATH"
	export DOTNET_ROOT="$HOME/.local/share/dotnet"
	export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi

prepend_path "$HOME/.conf_files/scripts"
prepend_path "$HOME/.conf_files/mono_scripts/sh"
prepend_path "$HOME/.conf_files/cc_scripts/bin"

export EDITOR=nano
export VISUAL=less

if cmd_exists "qemu-run"; then
	test -d "$HOME/VM" && export QEMURUN_VM_PATH="$HOME/VM"
fi

alias ls='ls --color=auto'
alias irssi='irssi -n lucie-cupcakes --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'
alias cc_flags_debug='$CC -g -O0 -D DEBUG -mtune=generic -fsanitize=address,leak -std=c99 -pedantic -Wall -Werror -Wextra'
alias cc_flags='$CC -Os -s -pipe -mtune=generic -std=c99 -pedantic -Wall -Werror -Wextra'

xz_full_autism() { xz -z -9 -e -T $(nproc) -v -v -v -k $@ ; }
fork_muted() { $@ >/dev/null 2>&1& }
alias _fm="fork_muted"

if cmd_exists dpkg; then
	apt_autopurge() {
		sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
	}
fi

[[ -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" ]] && \
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"
