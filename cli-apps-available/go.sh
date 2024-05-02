export GOROOT="$HOME/.local/share/go"
export GOPATH="$HOME/go"
export PATH="$GOROOT/bin:$PATH"

test -d "$GOPATH/bin" && export PATH="$GOPATH/bin:$PATH"

