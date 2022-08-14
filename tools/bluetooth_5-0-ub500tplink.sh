#!/bin/bash

if [ $(id -u) != "0" ]; then
	echo "You must be root to run this script."
	exit 1
fi

fwdir="/lib/firmware/rtl_bt"

curl https://raw.githubusercontent.com/Realtek-OpenSource/android_hardware_realtek/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_config >> "${fwdir}/rtl8761b_config.bin"
curl https://raw.githubusercontent.com/Realtek-OpenSource/android_hardware_realtek/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_fw >> "${fwdir}/rtl8761b_fw.bin"

if [ ! -f "${fwdir}/rtl8761bu_fw.bin" ]; then 
	ln -v -s "${fwdir}/rtl8761b_fw.bin" "${fwdir}/rtl8761bu_fw.bin"
fi

