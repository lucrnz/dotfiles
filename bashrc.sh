#!/usr/bin/bash
[[ $- != *i* ]] && return

export PS1="\[\033[38;5;225m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;189m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\] % \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\$ '

[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.conf_files/scripts" ] && export PATH="$HOME/.conf_files/scripts:$PATH"
[ -d "$HOME/.conf_files/mono_scripts/sh" ] && export PATH="$HOME/.conf_files/mono_scripts/sh:$PATH"
[ -d "$HOME/.conf_files/cc_scripts/bin" ] && export PATH="$HOME/.conf_files/cc_scripts/bin:$PATH"

if command -v nvim &>/dev/null; then
	export EDITOR=$(which nvim)
elif command -v vim &>/dev/null; then
	export EDITOR=$(which vim)
elif command -v nano &>/dev/null; then
	export EDITOR=$(which nano)
else
	echo "Bashrc couldnt find an editor. sorry"
fi

activate_nvm() {
	if ! command -v nvm &>/dev/null; then
		export NVM_DIR="$HOME/.nvm"
		if [ -d $NVM_DIR ]; then
			[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
			[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
			echo 'nvm activated'
		else
			echo 'nvm not found/not installed.'
		fi
	else
		echo 'nvm already activated'
	fi
}

activate_pyenv() {
	if ! command -v pyenv &>/dev/null; then
		if [ -d "$HOME/.pyenv/bin" ]; then
			export PATH="$HOME/.pyenv/bin:$PATH"
			eval "$(pyenv init -)"
			eval "$(pyenv virtualenv-init -)"
			echo 'pyenv activated'
		else
			echo 'pyenv not found/not installed.'
		fi
	else
		echo 'pyenv already activated'
	fi
}

export QEMURUN_VM_PATH="$HOME/VM"

alias ls='ls --color=auto'
alias irssi='irssi -n lucie_ow --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'

xz_full_autism() {
	xz -z -9 -e -T $(nproc) -v -v -v -k $@
}

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
