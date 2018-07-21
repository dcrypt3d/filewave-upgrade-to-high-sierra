#!/bin/bash
log="/var/tmp/depnotify.log"
CURRENTUSER=$(ls -l /dev/console | awk '{ print $3 }')

#fixlog
/bin/rm -rf $log
/usr/bin/touch $log

#stayawake
/usr/bin/caffeinate -d -i -m -u &

#start depnotify
/usr/bin/sudo sudo -u "$CURRENTUSER" /Applications/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &

#setup DEPNotify
/bin/sleep 2
echo "Command: MainTitle: Welcome" >> $log
echo "Command: MainText: Please wait while this computer is prepared" >> $log
echo "Command: Image: /usr/local/outset/logo.png" >> $log
echo "Command: WindowStyle: ActivateOnStep" >> $log
echo "Status: Running scripts..." >> $log

#enable applesetup on next boot
/bin/rm -rf /var/db/.AppleSetupDone

#wifi
/bin/rm -rf /var/db/ConfigurationProfiles/Setup/.profileSetupDone
/usr/bin/touch /var/db/.MBSkipWiFiSetupIfPossible

#language/region
/usr/bin/defaults write NSGlobalDomain AppleLanguages "(en-US)"
/usr/bin/defaults write NSGlobalDomain AppleLocale "en_US"

#Set Timezone & Location
uuid=$(/usr/sbin/system_profiler SPHardwareDataType | grep "Hardware UUID" | awk '{print $3 }')

/usr/sbin/systemsetup -setusingnetworktime off

# Enable Location Services Setting
/usr/bin/sudo -u _locationd defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd."$uuid" LocationServicesEnabled -int 1
/usr/bin/sudo -u _locationd defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd LocationServicesEnabled -int 1
/usr/bin/sudo -u _locationd defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.notbackedup LocationServicesEnabled -int 1
/usr/bin/sudo -u _locationd defaults write /var/db/locationd/Library/Preferences/ByHost/com.apple.locationd.notbackedup."$uuid" LocationServicesEnabled -int 1
/usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
/usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.locationmenu ShowSystemServices -int 1

#custom clients.plist
/bin/cp /usr/local/etc/scripts/location/clients.plist /var/db/locationd/clients.plist 
/usr/bin/sudo /bin/chmod 644 /var/db/locationd/clients.plist
/usr/bin/sudo /usr/sbin/chown -R _locationd:_locationd /var/db/locationd
/usr/bin/sudo /usr/bin/plutil -convert binary1 /var/db/locationd/clients.plist

/usr/sbin/systemsetup -setnetworktimeserver "$TimeServer"
/usr/bin/defaults write /Library/Preferences/com.apple.timezone.auto Active -bool true
/usr/sbin/systemsetup -setusingnetworktime on > /dev/null 2>&1
/usr/sbin/systemsetup -getnetworktimeserver
/usr/sbin/systemsetup -gettimezone

if [ "$(launchctl list | grep com.apple.locationd)" = "" ]; then
   /usr/bin/sudo /bin/launchctl load /System/Library/LaunchDaemons/com.apple.locationd.plist
else
   /usr/bin/sudo killall -9 locationd
fi

#com.apple.SetupAssistant.managed
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipCloudSetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipSiriSetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipPrivacySetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipiCloudStorageSetup -bool true

#cleanup
/bin/rm -rf /usr/local/outset/login-privileged-once/firstboot.sh

echo "Command: MainText: Process Complete" >> $log
echo "Status: Restarting..." >> $log
/bin/sleep 2
/bin/rm -rf $log
/sbin/shutdown -r now

