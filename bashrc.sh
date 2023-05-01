#!/usr/bin/env bash
[[ $- != *i* ]] && return
# ---------------------------------------
export PS1="\[\033[38;5;7m\][\A]\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;78m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[\033[38;5;69m\]\h\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;7m\]>\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;141m\]\w\[$(tput sgr0)\]\n\\$ \[$(tput sgr0)\]"
# ---------------------------------------
cmd_exists() { command -v $1 &>/dev/null ; }
prepend_path() { test -d "$@" && export PATH="$@:$PATH"; }
fork_muted() { $@ >/dev/null 2>&1& }
alias _fm="fork_muted"
# ---------------------------------------
prepend_path "/snap/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.conf_files/scripts"
prepend_path "$HOME/.config/composer/vendor/bin"
# ---------------------------------------
if cmd_exists dpkg; then
  apt_autopurge() {
    sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
  }
fi
# ---------------------------------------
cmd_exists "nano" && export EDITOR=nano
cmd_exists "vim" && export EDITOR=vim
cmd_exists "nvim" && export EDITOR=nvim
# ---------------------------------------
# C# .NET SDK
# ---------------------------------------
luc_cfg_install_dotnet() {
  target_dir="$HOME/.local/share/dotnet"
  if test -d "$target_dir"; then
    echo "dotnet is already installed"
  else
    mkdir -p "$target_dir" && \
    curl --tlsv1.2 -fsSL -o- https://dot.net/v1/dotnet-install.sh | bash -s -- -c STS --install-dir "$target_dir" && \
    echo "Restart your shell to use dotnet"
  fi
}
if test -d "$HOME/.dotnet/tools"; then
  prepend_path "$HOME/.dotnet/tools"
fi

if test -d "$HOME/.local/share/dotnet"; then
  export PATH="$HOME/.local/share/dotnet:$PATH"
  export DOTNET_ROOT="$HOME/.local/share/dotnet"
  export DOTNET_CLI_TELEMETRY_OPTOUT=1
fi

# ---------------------------------------
# Deno version manager & Deno packages
# ---------------------------------------
luc_cfg_install_dvm() {
  target_dir="$HOME/.local/share/dvm"
  if test -d "$target_dir"; then
    echo "dvm is already installed"
  else
    bp_hash="$(sha1sum $HOME/.bash_profile | cut -d ' ' -f 1)"
    bp_file="/tmp/$(date_fmt)_bp"

    cat $HOME/.bash_profile > $bp_file
    curl --tlsv1.2 -fsSL -o- https://deno.land/x/dvm/install.sh | sh
    mv $HOME/.dvm $target_dir

    if [ "$(sha1sum $HOME/.bash_profile | cut -d ' ' -f 1)" != "$bp_hash" ]; then      
      cat $bp_file > $HOME/.bash_profile

      if [ "$(sha1sum $HOME/.bash_profile | cut -d ' ' -f 1)" == "$bp_hash" ]; then
        echo "- bash_profile restored"
      else
        echo "- something went wrong while restoring bash_profile"
        echo "- use git to restore the changes on the file"
      fi
    fi

    rm $bp_file
    mkdir -p "$HOME/.deno/bin"
    touch "$HOME/.dvm_first_install"
    echo "Restart your shell to use dvm"
  fi
}

if test -d "$HOME/.local/share/dvm"; then
	export DVM_DIR="$HOME/.local/share/dvm"
	export PATH="$DVM_DIR/bin:$PATH"
  prepend_path "$HOME/.deno/bin"
fi

if test -f "$HOME/.dvm_first_install"; then
  rm "$HOME/.dvm_first_install" && \
  dvm install && \
  dvm use latest
fi

# ---------------------------------------
# Haskell Programming Language - https://www.haskell.org/platform/
# ---------------------------------------
luc_cfg_install_haskell() {
  if test -d "$HOME/.ghcup"; then
    echo "ghcup is already installed"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  fi
}

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

# ---------------------------------------
# Go programming language - https://go.dev/dl/
# ---------------------------------------
luc_cfg_install_go() {
  target_dir="$HOME/.local/share/go"
  if test -d "$target_dir"; then
    echo "Go is already installed"
  else
    tmp_dir="/tmp/$(date_fmt)_go"
    mkdir -p $tmp_dir
    curl --tlsv1.2 -fsSL -o- https://go.dev/dl/go1.20.3.linux-amd64.tar.gz | tar -C "$tmp_dir" -xzvf - && \
    mv "$tmp_dir/go" "$target_dir" && \
    mkdir -p "$HOME/go/bin"
    rm -rf $tmp_dir

    echo "Restart your shell to use go"
  fi
}
test -d "$HOME/.local/share/go" && export GOROOT=$HOME/.local/share/go
prepend_path "$GOROOT/bin"
test -d "$HOME/go" && export GOPATH="$HOME/go"
test -d "$HOME/go/bin" && prepend_path "$HOME/go/bin"
# ---------------------------------------
# Nim programming language - https://nim-lang.org/install_unix.html
# ---------------------------------------
luc_cfg_install_nim() {
  target_dir="$HOME/.local/share/nimble"
  if test -d "$target_dir"; then
    echo "Nim is already installed"
  else
    curl --tlsv1.2 -fsSL -o- https://nim-lang.org/choosenim/init.sh | sh && \
    mv $HOME/.nimble $target_dir && \
    echo "Restart your shell to use nim"
  fi
}
prepend_path "$HOME/.local/share/nimble/bin"
# ---------------------------------------
# Zig programming language - https://ziglang.org/download/
# ---------------------------------------
luc_cfg_install_zig() {
  target_dir="$HOME/.local/share/zig"
  if test -d "$target_dir"; then
    echo "Zig is already installed"
  else
    tmp_dir="/tmp/$(date_fmt)_zig"
    mkdir -p "$tmp_dir" && \
    curl --tlsv1.2 -fsSL -o- https://ziglang.org/download/0.10.1/zig-linux-x86_64-0.10.1.tar.xz | tar -C "$tmp_dir" -xJvf - && \
    mv $tmp_dir/zig-linux-x86_64-0.10.1 $target_dir
    echo "Restart your shell to use zig"
  fi
}
prepend_path "$HOME/.local/share/zig"
# ---------------------------------------
# Node version manager - https://github.com/nvm-sh/nvm
# ---------------------------------------
luc_cfg_install_nvm() {
  target_dir="$HOME/.local/share/nvm"
  if test -d "$target_dir"; then
    echo "nvm is already installed"
  else
    curl --tlsv1.2 -fsSL -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    mv $HOME/.nvm $target_dir && \
    touch "$HOME/.nvm_first_install" && \
    echo "Restart your shell to use nvm"
  fi
}

if test -d "$HOME/.local/share/nvm"; then
  export NVM_DIR="$HOME/.local/share/nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

if test -f "$HOME/.nvm_first_install"; then
  rm "$HOME/.nvm_first_install"
  nvm install --lts && \
  nvm use --lts && \
  npm update -g
  echo "Enjoy :)"
fi

# ---------------------------------------
# Rust programming language
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# ---------------------------------------

luc_cfg_install_rust() {
  target_dir="$HOME/.local/share/rustup"
  if test -d "$target_dir"; then
    echo "rustup is already installed"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && \
    mv $HOME/.rustup $target_dir && \
    echo "Restart your shell to use rustup"
  fi
}

test -f "$HOME/.cargo/env" && . "$HOME/.cargo/env"
# ---------------------------------------
alias ls='ls -l --color=auto'
alias irssi='irssi -n lucrnz --config=$HOME/.config/irssi/irssi.conf --home=$HOME/.config/irssi'
cmd_exists ffplay && alias ffplay_audio='ffplay -autoexit -nodisp'
# ---------------------------------------
test -f "$HOME/.conf_files/bashrc_${HOSTNAME}.sh" && \
	source "$HOME/.conf_files/bashrc_${HOSTNAME}.sh"
