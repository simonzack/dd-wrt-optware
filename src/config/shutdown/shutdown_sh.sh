#!/bin/sh

. /jffs/etc/config/lib/mount.sh
. /jffs/etc/config/shutdown/shutdown_helpers.sh

main(){
	local flash_pid=$1; shift
	trap "shutdown_fail $flash_pid;" INT TERM
	
	#try to unmount mounted partitions
	shutdown_log "unmounting /mnt"
	if ! unmount_wait 2 3 /mnt; then
		shutdown_log "failed to unmount /mnt"
		shutdown_fail $flash_pid
	fi
	
	shutdown_log "unmounting /opt"
	if ! unmount_wait 2 3 /opt; then
		shutdown_log "failed to unmount /opt"
		shutdown_fail $flash_pid
	fi
	
	#change root shell to /bin/sh in case logging-in is required after optware shutdown
	shutdown_log "changing root shell"
	. /jffs/etc/config/lib/chsh.sh
	chsh_simple root /bin/sh
	
	shutdown_success $flash_pid
}

main "$@"
