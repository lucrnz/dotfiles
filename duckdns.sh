#!/bin/bash
log_file=$HOME/.duckdns.log
output=$(curl -k -s "https://www.duckdns.org/update?domains=lucie-ow&token=69297e9b-d7fe-423c-b04b-3b6d5cd00c47&ip=")
echo "$(date +%Y%m%d_%H%M): $output" >> $log_file
exit 0

