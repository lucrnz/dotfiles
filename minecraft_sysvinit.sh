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
USERNAME='minecraft'

BACKUP_ROOT="/usr/local/backups/Hosts/Centauri/srv/${SERVICE}/"

MC_ROOT='/srv/minecraft'
MC_JAR='minecraft_server.jar'
MC_SETTINGS="$MC_ROOT/server.properties"

JAVA_FLAGS="-Xmx4G "
MC_FLAGS='nogui'


mc_run_as() {
	su -s "/bin/sh" -l $USERNAME -c "$1"
}


mc_is_running() {
    pgrep -u $USERNAME -f "$MC_JAR" >/dev/null
}


mc_notify() { # mc_notify "message"

	if mc_is_running
	then
		echo "Notifying users: $1"
		mc_run_as "tmux send-key 'say $1'"
	else
		echo "No users to Notify about: $1"
	fi
}


mc_start() {
        if mc_is_running
        then
                echo "$SERVICE is already running"
                return $?
        fi

        echo "$Starting $SERVICE."

	# Minecraft now (mostly) takes care of this sort of stuff.
	# mc_run_as "mv server.log server.log.last >/dev/null"

	mc_run_as "tmux new -d -s minecraft 'java $JAVA_FLAGS -jar $MC_JAR $MC_FLAGS'"
}


mc_stop() {
        if ! mc_is_running
        then
                echo "$SERVICE is not running."
		return 0
        fi

	echo "Stopping minecraft."
	mc_notify "SERVER GOING DOWN!"
	mc_run_as "tmux send-key 'stop'"
}


mc_status() {
	local start p end
        if mc_is_running
        then
		echo "$SERVICE is running."

		#
		# pretty print info about players.
		#

		mc_run_as "tmux send-key 'list'"

		start=`nl /srv/minecraft/logs/latest.log | grep "There are .* players online" | tail -n 1 | awk '{ print $1 }'`
		p=`grep "There are .* players online" /srv/minecraft/logs/latest.log | tail -n 1 | awk '{ print $6 }' | cut -d/ -f2`
		end=`expr $start + $p`
		p=`wc -l /srv/minecraft/logs/latest.log | cut -d' ' -f1`
		[ "$p" -lt "$end" ] && end="$p"

		ed -s /srv/minecraft/logs/latest.log << EOF
${start},${end}p
q
EOF

	else
                echo "$SERVICE is not running."
        fi
}


mc_backup() {

	mc_notify 'SERVER BACKUP ABOUT TO START!'
	mc_stop

	echo "Archiving server."
	if ! (cd "${MC_ROOT}/.." && tar cf - minecraft) \
		| xz -c >  "$BACKUP_ROOT"/minecraft-`date +"%Y-%m-%d.%H%M"`.tar.xz
	then
		echo 'Failed to backup minecraft server. Aborting!'
		exit 1;
	fi
}


mc_update() { # mc_update "x.y.z"
	local mc_jar need_restart to_ver

	mc_jar="${MC_ROOT}/${MC_JAR}"
	if mc_is_running
	then
		need_restart=yes
	else
		need_restart=no
	fi
	to_ver="$1"


	if [ -z "$1" ]; then
		echo "What version am I supposed to download?"
		echo "Ignoring your request."
		exit 127
	fi

	echo "need_restart=$?"

	if [ "$need_restart" = "yes" ]
	then
		mc_notify "SERVER WILL BE UPDATED TO $to_ver"
		mc_stop
	fi

	if ! mc_backup
	then
		echo "Backing up $SERVICE failed!"
		return 1
	fi

	echo "old sha1: `sha1sum $mc_jar`"
	rm -f "$mc_jar"
	if ! wget -O $mc_jar \
		"https://s3.amazonaws.com/Minecraft.Download/versions/${to_ver}/minecraft_server.${to_ver}.jar"
	then
		echo "Error downloading updated JAR."
		echo 'You may wish to manually restore server from backup!'
		return 1
	fi
	echo "new sha1: `sha1sum $mc_jar`"


	[ "$need_restart" = "yes" ] && echo mc_start

}


mc_world() {
	local old_world new_world default_props real_props

	new_world="$1"
	old_world="`grep '^level-name=' $MC_SETTINGS | cut -f2 -d=`"
	default_props="${MC_ROOT}/worlds/server.properties.defaults"
	real_props="${MC_ROOT}/worlds/${new_world}.properties"

	mc_notify "WARNING: CHANGING WORLDS FROM $old_world TO $new_world"
	sleep 3
	mc_stop

	unlink "$MC_SETTINGS"
	mkdir -p "${MC_ROOT}/worlds/$new_world"
	if [ ! -f "$real_props" ]; then
		mc_run_as "cp '$default_props' '$real_props'"
		echo "level-name=worlds/$new_world" >> "$real_props"
	fi
	ln -sf "$real_props" "$MC_SETTINGS"

	sleep 2
	mc_start
	sleep 2
	mc_notify "INFO: CURRENT WORLD IS $new_world"
}


mc_short_help() {
	echo "Usage: $0 {attach|backup|start|stop|status|restart|update|notify}"
	echo "       $0 world {name of world to create or change to}"
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
	echo "sudo service minecraft world {name of world to create or change to}"
	echo "	change / create world."
	echo "	Default properties come from worlds/server.properties.defaults"
	echo ''
	echo ''
	echo "sudo service minecraft notify \"message\""
	echo "  Notify all players of message."
	echo ''
	echo "sudo service minecraft update 1.7.4"
	echo "  backup server and update to version 1.7.4."
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

