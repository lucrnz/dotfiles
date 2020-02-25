#!/bin/sh
### BEGIN INIT INFO
# Provides: pulseaudio
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       PulseAudio system service
### END INIT INFO

# Alternative solution:
# Run pulseaudio as my user (lucie) without --system

# lucie_ow_: if you *dont* use --system it'll be happy to run as non-root.  It depends what your goal is.  If you want a system-wide pulseaudio, you need to run it as root and use --system (or do more complicated configuration).  If you just want it for your user, run it without --system and as your user.

DAEMON=/usr/bin/pulseaudio
PIDFILE=/run/pulseaudio_system.pid

start() {
  if [ -f /var/run/$PIDNAME ] && kill -0 $(cat /var/run/$PIDNAME); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service…' >&2
	$DAEMON --system=true --disallow-exit &
	sleep 1s
	pidof $DAEMON > $PIDFILE
	echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! ps -p $(cat "$PIDFILE") >/dev/null; then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service…' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

status() {
	if [ ! -f "$PIDFILE" ]; then
		echo 'Service not running' >&2
		return 1
	fi

	if ! ps -p $(cat "$PIDFILE") >/dev/null; then
		echo 'Service not running' >&2
		return 1
	else
		echo "Service is running at PID $(cat $PIDFILE)" >&2
		return 0
	fi
}

case "$1" in
	start)
    	start
    ;;
	stop)
    	stop
    ;;
	restart)
		stop; start
    ;;
	status)
		status
	;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
esac

