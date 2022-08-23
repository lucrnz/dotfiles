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

_include_all() {
	if test -d "$1"; then
		for f in $1/*.sh; do
			test -r "$f" && source "$f"
		done
		unset f
	fi
}

_include_all "$HOME/.conf_files/bashfun.d"
_include_all "$HOME/.conf_files/bashrc.d"

test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" && \
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"

unset _include_all

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
