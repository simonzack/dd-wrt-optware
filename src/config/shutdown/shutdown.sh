#!/opt/bin/bash

#to test:
#	the shutdown script should not start in /jffs, as it's unmounted by automount
#	$ cd /
#	$ exec /bin/sh
#	$ /opt/jffs/etc/config/shutdown/shutdown.sh

export PATH=/opt/bin:/opt/sbin:/opt/usr/sbin:$PATH

#ensure the shutdown script is only run once
LOCK_PATH="/tmp/SHUTDOWN.LCK"
LOCK_FILE=3
eval "exec $LOCK_FILE> $LOCK_PATH"
SHUTDOWN_EVENT="SHUTDOWN_EVENT"

#feedback parameters, don't export as there can be name collisions
LED_OFF=40000
LED_ON=40000

#maximum wait time for optware shutdown
MAX_WAIT_INTERVAL=-1

#mount /tmp to /jffs on startup:
#	the final unmount script & background processes during it's execution should have no handles to mounted partitions,
#	but as there are library dependencies, and the import paths cannot change, we need to copy imported scripts to /tmp, and remount a partition if the paths are absolute
#		(if the import paths are relative then remounting is not required, e.g. if we import from the script's path)
#	the final unmount script & background processes can then only use the copied scripts (for imports)
#	we can't use & remount /opt for absolute import paths, since services require it to be stopped, hence we remount /jffs
#	we do this on startup instead of just before switching shells, since automount unmounts /jffs
#		(automount only unmounts hdd partitions, not ramfs, so it won't unmount what we have just mounted)
#change current dir so jffs can be unmounted
cd /
/opt/jffs/etc/config/shutdown/tmp_jffs.sh || exit 1
. /jffs/etc/config/lib/event.sh
. /jffs/etc/config/lib/mount.sh
. /jffs/etc/config/shutdown/shutdown_helpers.sh

function shutdown_optware_signal(){
	/opt/etc/init.d/optK
	event_signal $SHUTDOWN_EVENT || true
}

function shutdown_unmount(){
	if ! is_mounted '/opt'; then
		return
	fi
	#kill mypage's process group (there's no service stop)
	#	use while instead of for .. in, due to some mypage processes being started by other ones, and kill might kill all of them
	shutdown_log "killing mypage"
	while pid=$(pgrep S99mypage | head -1) && [[ $pid ]]; do
		shutdown_log "killing mypage process group, pid: $pid"
		pgid=$(ps x -o "%p %r" | egrep "\s*$pid\s+[0-9]+" | sed -E 's/^\s*[0-9]+\s*//')
		kill -- "-$pgid"
	done
	shutdown_log "some partitions weren't unmounted by automount, running shutdown_sh.sh to unmount partitions"
	#switch shell to /bin/sh as bash has handles using /opt
	#	can't remount /opt as read-only, as partitions can't unmount normally even if mounted read-only
	#	can't copy bash to /tmp as it might have unknown lib dependencies (dlopen/dlsym, equivalent of GetProcAddress)
	#	the file lock is still kept after switching to /bin/sh
	exec /bin/sh "/jffs/etc/config/shutdown/shutdown_sh.sh" $flash_pid
}

function shutdown_main(){
	trap "event_wait_cleanup $SHUTDOWN_EVENT; exit 1;" INT TERM
	#run init.d stop script, this handles unmounting of both /mnt and /opt
	shutdown_log "shutting down optware"
	shutdown_optware_signal &
	#wait for the shutdown script to finish, and flash led's while doing so, to show that the script is working
	#	sh is used so that the process can be killed when switching to /bin/sh
	#	the feedback parameters are escaped with '$'
	/bin/sh -c "
		. /jffs/etc/config/lib/led.sh
		flash_led -1 $LED_OFF $LED_ON
	" &
	flash_pid=$!
	trap "event_wait_cleanup $SHUTDOWN_EVENT; shutdown_fail $flash_pid;" INT TERM
	if ! event_wait $MAX_WAIT_INTERVAL $SHUTDOWN_EVENT; then
		#optware shutdown timed out
		shutdown_log "optware shutdown timed out"
		event_wait_cleanup $SHUTDOWN_EVENT
		shutdown_fail $flash_pid
	fi
	trap "shutdown_fail $flash_pid;" INT TERM
	shutdown_log "optware shutdown completed"
	shutdown_log "checking if partitions are still mounted (automount doesn't unmount /opt)"
	#try to unmount partitions if still mounted
	shutdown_unmount
	#control not transferred to sh, hence all partitions are unmounted
	shutdown_log "partitions already unmounted by automount"
	shutdown_success $flash_pid
}

function main(){
	rm $LOCK_PATH
	flock -x $LOCK_FILE
	shutdown_main
	flock -u $LOCK_FILE
}

main
