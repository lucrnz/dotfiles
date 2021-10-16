# Go-lang
test -d "$HOME/.local/share/go" && export GOROOT=$HOME/.local/share/go
test -d "$HOME/go" && export GOPATH="$HOME/go"
prepend_path "$HOME/go/bin"