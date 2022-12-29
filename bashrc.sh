#!/bin/bash
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
