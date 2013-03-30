
This is a set of helper scripts for dd-wrt optware

Upon hitting the wps button (red button) on the asus n16, the router shuts down optware if the button is pressed once, reboot if twice, and cancels if pressed 3 times
I haven't found any proper shutdown scripts on the internet, so decided to roll my own. Hope you find this helpful.
If you aren't using the asus n16 router, you might need to change some gpio button constants in led.sh

Tested on basmaf optware take 2, DD-WRT v24-sp2 (09/22/12) mega (SVN revision 20006)
