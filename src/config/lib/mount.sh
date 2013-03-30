#!/bin/sh

is_mounted(){
	local mountPart=$1; shift
	grep -qs $mountPart /proc/mounts
	return $?
}

unmount_wait(){
	local retry_num=$1; shift
	local wait_time=$1; shift
	n=1
	local last
	for last; do true; done
	while is_mounted $last; do
		echo "umount $@"
		#use the busybox version in-case opt is to be unmounted
		/bin/umount $@ && return 0
		[ $n -ge $retry_num ] && return 1
		sleep $wait_time
		let n+=1
	done
}
