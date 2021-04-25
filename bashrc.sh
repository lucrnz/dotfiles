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

test -d "/usr/bin/watcom/binl" && export PATH="$PATH:/usr/bin/watcom/binl"
test -d "/usr/local/go/bin" && export PATH="$PATH:/usr/local/go/bin"
test -d "/snap/bin/" && export PATH="/snap/bin/:$PATH"
test -d "$HOME/bin" && export PATH="$HOME/bin:$PATH"
test -d "$HOME/.local/bin" && export PATH="$HOME/.local/bin:$PATH"
test -d "$HOME/go/bin" && export PATH="$HOME/go/bin:$PATH"
test -d "$HOME/.conf_files/scripts" && export PATH="$HOME/.conf_files/scripts:$PATH"
test -d "$HOME/.conf_files/mono_scripts/sh" && export PATH="$HOME/.conf_files/mono_scripts/sh:$PATH"
test -d "$HOME/.conf_files/cc_scripts/bin" && export PATH="$HOME/.conf_files/cc_scripts/bin:$PATH"
test -d "$HOME/.nimble/bin" && export PATH="$HOME/.nimble/bin:$PATH"
test -f "$HOME/.cargo/env" && source "$HOME/.cargo/env"

export EDITOR=nano
export QEMURUN_VM_PATH="$HOME/VM"

if [ "$HOSTNAME" == "dreams" ]; then
	test -d "/mnt/D_DRIVE/QEMU" && export QEMURUN_VM_PATH="$HOME/VM:/mnt/D_DRIVE/QEMU"
fi

alias ls='ls --color=auto'
alias irssi='irssi -n lucie-cupcakes --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'
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

find_pendrive() {
	fd=$(sudo fdisk -l)
	echo "$fd" | grep 7864320000
	echo "$fd" | grep 30979129344
}

if command -v dpkg &>/dev/null; then
	apt_autopurge() {
		sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
	}
fi

[[ "$HOSTNAME" == "thinkpad" ]] && [[ -f "$HOME/.conf_files/bashrc_thinkpad.sh" ]] && \
	source "$HOME/.conf_files/bashrc_thinkpad.sh"
