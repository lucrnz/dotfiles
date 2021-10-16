if cmd_exists "qemu-run"; then
  test -d "$HOME/VM" && export QEMURUN_VM_PATH="$HOME/VM"
fi
