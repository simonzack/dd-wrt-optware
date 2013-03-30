#!/opt/bin/bash

#import using /opt so there's no handle to /jffs
. /opt/jffs/etc/config/lib/mount.sh
. /opt/jffs/etc/config/shutdown/shutdown_helpers.sh

function main(){
	#copy the scripts required for shutdown to /tmp, so no handles to /opt or /jffs are kept
	cd /
	if ! unmount_wait 2 1 /jffs; then
		shutdown_log "failed to unmount jffs"
		exit 1
	fi
	mkdir -p /tmp/jffs/etc/config
	mount --bind -n /tmp/jffs /jffs
	cp -r /opt/jffs/etc/config/shutdown /jffs/etc/config/shutdown
	cp -r /opt/jffs/etc/config/lib /jffs/etc/config/lib
}

main
