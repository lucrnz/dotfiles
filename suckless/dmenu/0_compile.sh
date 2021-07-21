#!/bin/bash
CFLAGS="-O3 -s -march=native" make dmenu stest
dest=$HOME/.local/bin
destSys=/usr/bin

set_sys_symlink() {
	if [ ! -f "${destSys}/$1" ] && [ -f "${dest}/$1" ];  then
		sudo ln -s "${dest}/$1" "${destSys}/$1"
	fi
}

if [ ! -f "${dest}/dmenu_run" ]; then
	cp -v "$(pwd)/dmenu_run" "${dest}/"
fi

if [ ! -f "${dest}/dmenu_path" ]; then
	cp -v "$(pwd)/dmenu_path" "${dest}/"
fi

if [ -f "$(pwd)/dmenu" ]; then
	mv -v "$(pwd)/dmenu" "${dest}/"
fi


if [ -f "$(pwd)/stest" ]; then
	mv -v "$(pwd)/stest" "${dest}/"
fi

# system symlinks:
set_sys_symlink stest
set_sys_symlink dmenu_path
set_sys_symlink dmenu_run
set_sys_symlink dmenu

make clean

