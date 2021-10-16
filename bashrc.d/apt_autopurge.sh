if cmd_exists dpkg; then
  apt_autopurge() {
    sudo apt-get purge $(dpkg -l | grep '^rc' | awk '{print $2}')
  }
fi
