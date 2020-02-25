#!/bin/sh

### BEGIN INIT INFO
# Provides:   minecraft
# Required-Start: $local_fs $remote_fs
# Required-Stop:  $local_fs $remote_fs
# Should-Start:   $network
# Should-Stop:    $network
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description:    Minecraft server
# Description:    Starts the minecraft server
### END INIT INFO

#Settings
SERVICE='minecraft'
USERNAME='lucie'
BACKUP_ROOT="/home/lucie/backup"
MC_ROOT='/home/lucie/minecraft_server'
MC_JAR='forgesv.jar'
MC_SETTINGS="$MC_ROOT/server.properties"
JAVA_FLAGS="-Xmx2G "
MC_FLAGS='nogui'

mc_run_as() {
	su -s "/bin/sh" -l $USERNAME -c "$@"
}

mc_is_running() {
    pgrep -u $USERNAME -f "$MC_JAR" >/dev/null
}

mc_notify() { # mc_notify "message"
	if mc_is_running
	then
		echo "Notifying users: $1"
		mc_run_as "tmux send-keys -t minecraft.0 'say $1'"
	else
		echo "No users to Notify about: $1"
	fi
}


mc_start() {
	if mc_is_running; then
		echo "$SERVICE is already running"
		return $?
	fi

	echo "$Starting $SERVICE."

	mc_run_as "tmux new -d -s minecraft -c '$MC_ROOT' '/bedrock/bin/strat artix java $JAVA_FLAGS -jar $MC_JAR $MC_FLAGS'"
}

mc_stop() {
        if ! mc_is_running
        then
                echo "$SERVICE is not running."
		return 0
        fi

	echo "Stopping minecraft."
	mc_notify "SERVER GOING DOWN!"
	mc_run_as "tmux send-keys -t minecraft.0 'stop'"
}


mc_status() {
	local start p end
        if mc_is_running
        then
		echo "$SERVICE is running."

		#
		# pretty print info about players.
		#

		mc_run_as "tmux send-keys -t minecraft.0 'list'"

		start=`nl $MC_ROOT/logs/latest.log | grep "There are .* players online" | tail -n 1 | awk '{ print $1 }'`
		p=`grep "There are .* players online" /srv/minecraft/logs/latest.log | tail -n 1 | awk '{ print $6 }' | cut -d/ -f2`
		end=`expr $start + $p`
		p=`wc -l $MC_ROOT/logs/latest.log | cut -d' ' -f1`
		[ "$p" -lt "$end" ] && end="$p"

		ed -s $MC_ROOT/logs/latest.log << EOF
${start},${end}p
q
EOF

	else
                echo "$SERVICE is not running."
        fi
}


mc_backup() {
	mc_notify 'Starting server backup!'
	mc_run_as "tmux send-keys -t minecraft.0 'save-all'"
	sleep 5s;

	echo "Archiving server."

	backup_file="$BACKUP_ROOT"/minecraft-`date +"%Y-%m-%d.%H%M"`.tar
	(cd "${MC_ROOT}"; tar cvf "$backup_file" .) && xz -9 -e -vvv "$backup_file"

	if [ "$?" != "0" ]; then
		echo 'Failed to backup minecraft server. Aborting!'
		exit 1;
	fi
	sync
}

mc_short_help() {
	echo "Usage: $0 {attach|backup|start|stop|status|restart|notify}"
}

mc_long_help() {
	echo ''
	echo "sudo service minecraft attach"
	echo "	attach to server console."
	echo "  detach with control+b d"
	echo "	see man tmux and Minecraft wiki for more info."
	echo ''
	echo "sudo service minecraft backup"
	echo "	backup the server."
	echo ''
	echo "sudo service minecraft start"
	echo "	start minecraft server."
	echo ''
	echo "sudo service minecraft stop"
	echo "	stop minecraft server."
	echo ''
	echo "sudo service minecraft restart"
	echo "	restart minecraft server."
	echo ''
	echo "sudo service minecraft status"
	echo "	check if running"
	echo ''
	echo "sudo service minecraft notify \"message\""
	echo "  Notify all players of message."
	echo ''
}


case "$1" in
        start)
                mc_start
                ;;
        stop)
                mc_stop
                ;;
        restart)
                mc_stop
                mc_start
                ;;
        status)
                mc_status
                ;;
	backup)
		mc_backup
		;;
        update)
                mc_update "$2"
                ;;
	notify)
		shift
		mc_notify "$*"
		;;
        attach)
		mc_run_as "tmux attach -t minecraft"
                ;;
	world)
		shift
		mc_world $@
		;;
	short_help)
		mc_short_help
                exit 0
		;;
	long_help)
		mc_long_help
                exit 0
		;;
        *)
		mc_short_help
                exit 1
                ;;
esac

exit 0

