#!/bin/sh
### BEGIN INIT INFO
# Provides: disable-ryzen-c6-state
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       AMD Ryzen disable C6 state
### END INIT INFO

case "$1" in
	start)
    	/opt/zenstates/service_start.sh
    ;;
	stop)
    	/opt/zenstates/service_stop.sh
    ;;
	*)
		echo "Usage: $0 {start|stop}"
esac

