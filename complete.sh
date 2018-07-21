#!/bin/bash

log="/var/log/fwcld.log"

echo "Status: Preparing services..." >> $log

# Show hostname at login window
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Set the login window to name and password
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Turn SSH & Remote Desktop on
/usr/sbin/systemsetup -setremotelogin on
/usr/sbin/systemsetup -setwakeonnetworkaccess on
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users locadmin -access -on -privs -all
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -activate

#disable root login
/usr/bin/dscl . -create /Users/root UserShell /usr/bin/false

# Turn off Gatekeeper
/usr/sbin/spctl --master-disable
/usr/bin/defaults write /Library/Preferences/com.apple.security GKAutoRearm -bool false
/usr/bin/defaults write /Library/Preferences/com.apple.security RSAMaxKeySize -int 32768

#disable filevault prompt
defaults write /Library/Preferences/com.apple.MCX cachedaccounts.askForSecureTokenAuthBypass -bool true

#cleanup
echo "Status: Cleaning up..." >> $log
/usr/bin/dscl localhost delete /Local/Default/Users/admin
/bin/rm -rf /Users/admin
/usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser
/usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUserUID
/usr/bin/defaults delete /Library/Preferences/com.apple.loginwindow LoginHook
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
/bin/rm -rf /usr/local/outset/login-privileged-once/secondboot.sh
/bin/rm -rf /Applications/DEPNotify.app

echo "Status: Installing software..." >> $log
/bin/sleep 5

echo "Command: DeterminateOffReset:" >> $log
echo "Status: Setup Complete" >> $log
/bin/sleep 2
echo "Command: RestartNow:" >> $log

exit 0
