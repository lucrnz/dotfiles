test -d "/media/D_DRIVE/QEMU" && export QEMURUN_VM_PATH="$HOME/VM:/media/D_DRIVE/QEMU"

if cmd_exists mocp; then
    test -d "$HOME/.config/moc" && alias mocp="mocp -M $HOME/.config/moc"
fi
