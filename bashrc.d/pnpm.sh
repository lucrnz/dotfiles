# pnpm package manager - https://pnpm.io/
# curl -fsSL https://get.pnpm.io/install.sh | sh -

if test -d "$HOME/.local/share/pnpm"; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi
