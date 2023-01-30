#!/usr/bin/env bash
## ---------------------------------------
# I made this script for GiHhub Codespaces
# I have no idea if it works fine for a normal environment
## ---------------------------------------

if [ "$HOME" == "/home/codespace" ]; then
    case $(hostname) in codespace*)
        DF_PATH="$(pwd)"
        ln -s "$DF_PATH" "$HOME/.conf_files"
        test -f "$HOME/.bashrc" && rm "$HOME/.bashrc"
        ln -s "$DF_PATH/.bashrc" "$HOME/.bashrc"

        test -d "$HOME/.local/share/bin" || mkdir -p "$HOME/.local/share/bin"
        curl https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o "$HOME/.local/share/bin/nvim" && \
        chmod +x "$HOME/.local/share/bin/nvim"
    esac
fi
