# Deno version manager & Deno packages
# curl -fsSL https://dvm.deno.dev | sh

if test -d "$HOME/.dvm"; then
	export DVM_DIR="$HOME/.dvm"
	export PATH="$DVM_DIR/bin:$PATH"

	if test -d "$HOME/.deno/bin"; then
		export PATH="$HOME/.deno/bin:$PATH"
	fi
fi

