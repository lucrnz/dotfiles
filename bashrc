[[ $- != *i* ]] && return

if [ "$(which lolcat >/dev/null 2>&1; echo -n $?)" == "0" ] && [ "$(which python >/dev/null 2>&1; echo -n $?)" == "0" ]; then
	HAVE_LOLCAT="true"
	lololps1() {
		# Make a RAINBOW COLORED bash prompt
		# Requires lolcat and python

		# Implement my version of \w because I can't just outright expand a PS1 string
		# Actually, bash 4.4 can do it.... I'm not running 4.4
		# Bash argument modification is crazy
		# Replace $HOME with ~
		mypwd=${PWD/#$HOME/"~"}
		# Greedy delete everything before the last forward slash
		#mypwd=${mypwd##*/}

		# Get the current python virtualenv
		myvenv=$(python -c 'import sys;sys.stdout.write(sys.prefix.split("/")[-1] if hasattr(sys, "real_prefix") or hasattr(sys, "base_prefix") and sys.prefix != sys.base_prefix else "")')
		# surround with square braces if non-empty
		myvenv="${myvenv:+[$myvenv]}"

		# Make a persistent, incrementing seed to make a smooth rainbow effect from line to line
		if [ -z ${LOLCAT_SEED+x} ]; then LOLCAT_SEED=1; else let "LOLCAT_SEED += 1"; fi

		PS1="$myvenv$HOSTNAME $mypwd"
		PS1="${PS1/duck/🦆}"
		PS1="${PS1/duck-kudu/🦌}"

		# Colorize it
		# lolcat -f forces escape sequences even when lolcat doesn't think they'd matter
		# lolcat -F changes the frequency of the rainbow
		PS1=$(echo "$PS1" | lolcat -f -F 0.7 -S $LOLCAT_SEED 2>/dev/null)
		# Strip the "reset colors to normal" commands
		PS1=$(echo "$PS1" | sed $'s/\033\[0m//g')
		# Replace escape sequences with [escaped escape sequences]
		# e.g.: \[\033[38;5;39m\]
		PS1=$(echo "$PS1" | sed -r $'s/\033''(\[[0-9]+;[0-9]+;[0-9]+m)/\\\[\\033\1\\\]/g')
		PS1="${PS1}\[\033[0m\]% "
	}
	PROMPT_COMMAND=lololps1
else
	HAVE_LOLCAT="false"
	export PS1="\[\033[38;5;51m\]\u\[$(tput sgr0)\]\[\033[38;5;33m\]@\[$(tput sgr0)\]\[\033[38;5;15m\]\h:\[$(tput sgr0)\]\[\033[38;5;219m\][\[$(tput sgr0)\]\[\033[38;5;141m\]\w\[$(tput sgr0)\]\[\033[38;5;219m\]]\[$(tput sgr0)\]\[\033[38;5;45m\]>\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
fi

#PS1='[\u@\h \W]\$ '

[ -f "$HOME/.is_phone" ] && PS1=$(echo "$PS1" | sed 's/\\h/phone/g')
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.conf_files/scripts" ] && export PATH="$HOME/.conf_files/scripts:$PATH"

export EDITOR=$(which nvim)
export QEMURUN_VM_PATH="/media/pearl/VM"

if [ "$HAVE_LOLCAT" == "true" ]; then
	l() {
		ls -l $@ | lolcat
	}
else
	l() {
		ls -l -color=auto $@
	}
fi

alias irssi='irssi -n lucie_ow --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'

fork_muted() {
	$@ >/dev/null 2>&1 &
}

ramdisk() {
	target="/tmp/ramdisk"
	if [ -d $target ]; then
		echo "$target already exists??"
	else
		mkdir $target
		sudo mount -t tmpfs -o size=$1 ramdisk_user /tmp/ramdisk
	fi
}

#if [ "$HOSTNAME" == "dreams" ]; then
#	if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
#		startx
#	fi
#fi
