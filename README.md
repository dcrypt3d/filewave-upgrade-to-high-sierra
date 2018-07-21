# filewave-upgrade-to-high-sierra
Use Filewave &amp; DEPNotify to upgrade to High Sierra

This is my current workflow for imaging High Sierra using and external USB & DEPNotify.

1. Boot external USB drive (hold option key and enter firmware password)
2. Auto login & outset runs upgrade.sh
3. Local drive is formated for APFS & Deploys High Sierra image using ASR tool
4. Local drive is remounted, CreateUserPkg, Firstboot, Firmware Update, & Firmware Password Remove packages are installed and host reboots
5. Auto login as admin, outset runs firstboot.sh and DEPNotify then host reboots
6. User or Admin completes Setup Assistant & DEP Management Process
7. Auto login as admin, outset runs secondboot.sh and DEPNotify to sync with Filewave
8. Lowest priority fileset runs complete.sh then reboots

After this workflow completes, the computer is ready for user to login

#upgrade.sh
This script should be executed at login from an external drive where you have your high sierra image in /images.
You should create a firmware upgrade package for 10.12 machines, a CreateUserPkg for auto admin login on next boot, a package to remove the firmware password, outset and a package that deploys firstboot.pkg

#firstboot.pkg/firstboot.sh
This script should be packaged to install to /usr/local/outset/login-privileged-once/ along with any other packages necessary after SetupAssistant has been completed

#secondboot.pkg/secondboot.sh
This script should be packaged in firstboot.pkg to install secondboot.pkg to /usr/local/outset/login-privileged-once/ so that it will launch after completing SetupAssistant

#complete.sh
This script should be lowest priority fileset in Filewave so that it will run after client syncs all other filesets
