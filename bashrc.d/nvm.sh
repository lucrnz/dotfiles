# Node version manager
# https://github.com/nvm-sh/nvm#installing-and-updating
# mv $HOME/.nvm $HOME/.local/share/nvm
# nvm install node
# nvm use node

if test -d "$HOME/.local/share/nvm"; then
  export NVM_DIR="$HOME/.local/share/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi
