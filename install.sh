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
        ln -s "$DF_PATH/bashrc.sh" "$HOME/.bashrc"
        curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o "$HOME/.local/bin/nvim" && \
        chmod +x "$HOME/.local/bin/nvim"
    esac
fi
