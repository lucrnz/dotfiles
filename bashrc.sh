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

export PS1="\[\033[38;5;225m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;189m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]\n% \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\$ '

[ -d "/usr/bin/watcom/binl" ] && export PATH="$PATH:/usr/bin/watcom/binl"
[ -d "/usr/local/go/bin" ] && export PATH="$PATH:/usr/local/go/bin"
[ -d "/snap/bin/" ] && export PATH="/snap/bin/:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/go/bin" ] && export PATH="$HOME/go/bin:$PATH"
[ -d "$HOME/.conf_files/scripts" ] && export PATH="$HOME/.conf_files/scripts:$PATH"
[ -d "$HOME/.conf_files/mono_scripts/sh" ] && export PATH="$HOME/.conf_files/mono_scripts/sh:$PATH"
[ -d "$HOME/.conf_files/cc_scripts/bin" ] && export PATH="$HOME/.conf_files/cc_scripts/bin:$PATH"

export EDITOR=nano
export QEMURUN_VM_PATH="$HOME/VM"
export CC=gcc

alias ls='ls --color=auto'
alias irssi='irssi -n lucie_ow --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'

alias cc_flags_debug='$CC -g -O0 -D DEBUG -mtune=generic -fsanitize=address,leak -std=c99 -pedantic -Wall -Werror -Wextra'
alias cc_flags='$CC -Os -s -pipe -mtune=generic -std=c99 -pedantic -Wall -Werror -Wextra'

xz_full_autism() { xz -z -9 -e -T $(nproc) -v -v -v -k $@ ; }
fork_muted() { $@ >/dev/null 2>&1& }
alias _fm="fork_muted"

ramdisk() {
	target="/tmp/ramdisk"
	if [ -d $target ]; then
		echo "$target already exists??"
	else
		mkdir $target
		sudo mount -t tmpfs -o size=$1 ramdisk_user /tmp/ramdisk
	fi
}

if command -v dpkg &>/dev/null; then
	apt_autopurge() {
		sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
	}
fi

if [ "$HOSTNAME" == "thinkpad" ]; then
	export LANG="en_US.UTF-8"
fi
