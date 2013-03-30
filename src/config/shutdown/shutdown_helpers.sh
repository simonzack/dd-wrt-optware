#!/bin/sh

. /jffs/etc/config/lib/led.sh

shutdown_log(){
	#don't use logger, otherwise only parts of the shutdown log will be present in /opt, which will be confusing
	echo "$@"
	echo $(/bin/date +"%Y %b %e %X") $(/bin/hostname) "optware unmount shutdown ($$): " "$@" >> /var/log/shutdown
}

shutdown_success(){
	#switch off power led to show the script has finished (it's not switched off by just killing $flash_pid)
	shutdown_log "successfully shutdown"
	local flash_pid=$1; shift
	kill $flash_pid
	led_off
	exit 0
}

shutdown_fail(){
	shutdown_log "failed to shutdown"
	local flash_pid=$1; shift
	kill $flash_pid
	led_on
	exit 1
}
