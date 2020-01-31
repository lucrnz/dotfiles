[[ $- != *i* ]] && return

export PS1="\[\033[38;5;51m\]\u\[$(tput sgr0)\]\[\033[38;5;33m\]@\[$(tput sgr0)\]\[\033[38;5;15m\]\h:\[$(tput sgr0)\]\[\033[38;5;219m\][\[$(tput sgr0)\]\[\033[38;5;141m\]\w\[$(tput sgr0)\]\[\033[38;5;219m\]]\[$(tput sgr0)\]\[\033[38;5;45m\]>\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
#PS1='[\u@\h \W]\$ '

[ -f "$HOME/.is_phone" ] && PS1=$(echo "$PS1" | sed 's/\\h/phone/g')

[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"
[ -d "$HOME/.conf_files/scripts" ] && export PATH="$HOME/.conf_files/scripts:$PATH"

export EDITOR=$(which nano)

alias ls='ls -l --color=auto'
alias irssi='irssi -n lucie_ow --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'


if [ "$HOSTNAME" == "dreams" ]; then
	if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
		startx
	fi
fi
