#!/usr/bin/env bash

# Fix Some polybar modules

dir="$HOME/.config/polybar"
module="$dir/modules.ini"

# Battery Module
BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
AC=$(ls /sys/class/power_supply | grep AC | head -n 1)
if [[ "$BAT" ]]; then
	sed -i -e "s/battery = .*/battery = $BAT/g" $module
fi
if [[ "$AC" ]]; then
	sed -i -e "s/adapter = .*/adapter = $AC/g" $module
fi

# Network (Wifi) Module
IFACE=$(ip link | awk '/state UP/ {print $2}' | tr -d :)
if [[ "$IFACE" ]]; then
	sed -i -e "s/interface = .*/interface = $IFACE/g" $module
fi

# Reload Config
polybar-msg cmd restart
