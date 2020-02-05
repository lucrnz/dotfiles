#!/bin/bash

while true; do
sleep 5s
out=$(ps h -C smbd -o pid,args | grep /tmp/qemu-smb | gawk '{print "pid="$1";conf="$6}')

if [ "$out" != "" ]; then
eval $out
echo "[global]
allow insecure wide links = yes
[qemu]
follow symlinks = yes
wide links = yes
acl allow execute always = yes" >> $conf
smbcontrol --configfile=$conf $pid reload-config
exit 0
fi
done



