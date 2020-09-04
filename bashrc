[[ $- != *i* ]] && return

export PS1="\[\033[38;5;225m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;189m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\] % \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\$ '

[ -f "$HOME/.is_phone" ] && PS1=$(echo "$PS1" | sed 's/\\h/phone/g')
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.conf_files/scripts" ] && export PATH="$HOME/.conf_files/scripts:$PATH"

export EDITOR=$(which nvim)
export QEMURUN_VM_PATH="$HOME/VM"

alias ls='ls --color=auto'
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
