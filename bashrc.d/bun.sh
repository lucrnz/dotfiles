# Bun
if test -d "$HOME/.local/share/bun"; then
	export BUN_INSTALL="$HOME/.local/share/bun"
	export PATH="$BUN_INSTALL/bin:$PATH"
fi

