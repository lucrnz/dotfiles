export GOROOT=$HOME/.local/share/go
export GOPATH=$HOME/go
export GOBIN=/usr/local/go/bin:$HOME/go/bin
alias ls="ls --color=auto"

prepend_path "$HOME/local/nvim/bin"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

