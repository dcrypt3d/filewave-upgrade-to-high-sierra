#!/bin/bash

CURRENTUSER=$(ls -l /dev/console | awk '{ print $3 }')

log="/var/log/fwcld.log"

#caffeinate
/usr/bin/caffeinate -d -i -m -u &

/usr/bin/sudo sudo -u "$CURRENTUSER" /Applications/DEPNotify.app/Contents/MacOS/DEPNotify -filewave -fullScreen &

/bin/sleep 5

# Setup DEPNotify
echo "Command: MainTitle: Welcome" >> $log
echo "Command: Image: /usr/local/outset/logo.png" >> $log
echo "Command: WindowStyle: ActivateOnStep" >> $log
echo "Status: Starting..." >> $log

/bin/sleep 5

echo "Command: MainText: Please wait while your computer is configured" >> $log
echo "Status: Installing updates..." >> $log

/usr/sbin/softwareupdate -ia

#send complete.sh as lowest priority fileset to this machine that cleans up and restarts machine
