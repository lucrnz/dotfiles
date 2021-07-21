#!/bin/bash
CFLAGS="-O3 -s -march=native" make st

if [ -f "$(pwd)/st" ]; then
	mv -v "$(pwd)/st" "$HOME/.local/bin/" && sync
fi

make clean

