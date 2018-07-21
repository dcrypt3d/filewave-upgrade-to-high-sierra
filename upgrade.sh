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
echo "Command: MainText: Imaging computer" >> $log
echo "Command: Image: /logo.png" >> $log
echo "Command: WindowStyle: ActivateOnStep" >> $log
echo "Status: Starting..." >> $log

/bin/sleep 2
echo "Status: Formatting Hard Drive..." >> $log
/usr/sbin/diskutil umount "/Volumes/Macintosh HD"
/usr/sbin/diskutil eraseDisk apfs "Macintosh HD" /dev/disk0

/bin/sleep 2
echo "Status: Deploying Image..." >> $log
/usr/sbin/asr restore --source /images/osx_custom-10.13.6-17G65.apfs.dmg --target /dev/disk1 --erase --noprompt --noverify

/bin/sleep 2
echo "Status: Preparing Startup Disk..." >> $log
/usr/sbin/diskutil mount /dev/disk1s1
/usr/bin/touch /Volumes/Macintosh\ HD/var/db/.AppleSetupDone
/usr/sbin/installer -pkg /pkg/outset.pkg -target /Volumes/Macintosh\ HD/
/usr/sbin/installer -pkg /pkg/firstboot.pkg -target /Volumes/Macintosh\ HD/
/usr/sbin/installer -pkg /pkg/adminautologin.pkg -target /Volumes/Macintosh\ HD/
/usr/sbin/installer -pkg /pkg/firmwareupdate.pkg -target /Volumes/Macintosh\ HD/
/usr/sbin/installer -pkg /pkg/firmwarepasswdremove.pkg -target /Volumes/Macintosh\ HD

#Disable TimeMachine
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#disablesetupjunk
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipCloudSetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipSiriSetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipPrivacySetup -bool true
/usr/bin/defaults write /Volumes/My\ HD/Library/Preferences/com.apple.SetupAssistant.managed SkipiCloudStorageSetup -bool true

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

sw_build=$(sw_vers -buildVersion)

if [[ ${osvers} -ge 7 ]]; then

 for USER_TEMPLATE in "/Volumes/Macintosh HD/System/Library/User Template"/*
  do
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudDiagnostics -bool TRUE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeePrivacy -bool TRUE
    /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
  done

 for USER_HOME in "/Volumes/Macintosh HD/Users"/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ]; then
      if [ ! -d "${USER_HOME}"/Library/Preferences ]; then
        /bin/mkdir -p "${USER_HOME}"/Library/Preferences
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}"/Library
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ -d "${USER_HOME}"/Library/Preferences ]; then
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudDiagnostics -bool TRUE
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeePrivacy -bool TRUE
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeSiriSetup -bool TRUE
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
      fi
    fi
  done
fi

echo "Status: Done" >> $log
/bin/sleep 2
echo "Command: RestartNow:" >> $log

