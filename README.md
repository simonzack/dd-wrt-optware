
Description
===========
This is a set of helper scripts for dd-wrt optware

Included
========
A shutdown script which properly shuts down and unmounts optware
A proper usb automount
A wps script which triggers the shutdown script by default on pressing the wps button, and can be configured

USB Automount
-------------
The default usb automount buggy, usb.startup mounts /opt and /mnt automatically

Change the partition numbers if needed

Shutdown Script
-------------
/opt and /mnt are unmounted on shutdown
If shutdown succeeds the power light will turn off as an indicator, otherwise it will turn off
The gpio constant for the power light needs changing if this is run on another router

WPS Script
----------
Upon hitting the wps button (red button) on the asus n16, the router shuts down optware if the button is pressed once, reboot if twice, and cancels if pressed 3 times
The gpio constant for the power light needs changing if this is run on another router

Install
-------
run stripMountComments.py to generate the startup script and put it in nvram, or go to Administration > Commands > Startup in the web ui
after rebooting:
$ mkdir /opt/jffs/etc/
copy everything in ./config to /opt/jffs/etc/config

Compatability
=============
Tested on basmaf optware take 2, DD-WRT v24-sp2 (09/22/12) mega (SVN revision 20006)
