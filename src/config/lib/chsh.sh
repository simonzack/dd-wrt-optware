#!/bin/sh

chsh_simple(){
	local username=$1; shift
	local usershell=$1; shift
	#/etc/passwd is linked to /tmp/etc/passwd
	local passwdPath="/tmp/etc/passwd"
	local passwdTmpPath="/tmp/etc/passwd_copy"
	rm $passwdTmpPath
	while read -r line; do
		if echo $line | grep -q "^$username:"; then
			echo -n $line | cut -d":" -f-6 | awk '{printf("%s",$0);}' >> $passwdTmpPath
			echo ":$usershell" >> $passwdTmpPath
		else
			echo $line >> $passwdTmpPath
		fi
	done <$passwdPath
	mv $passwdTmpPath $passwdPath
}
