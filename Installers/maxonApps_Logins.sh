#!/bin/zsh

########################################################################################################
# PLEASE READ                                                                                          #
# Add Maxon credentials in parameters 4 email & 5 pw                                                   #
# Collect the Versions here https://www.maxon.net/en/downloads and add them to the following variables #
# This script works for patching too. ZBrush needs to be deleted before updating                       #
########################################################################################################

maxonAppVER="2024.4.0"
cinemaYEAR="2024"
cinema4dVER="2024.4.1"
zBrushVER="2024.0.4"
redshiftVER="3.6.01_379ab502"
magicBulletVER="2024.0.1"
trapcodeVER="2024.0.2"
universeVER="2024.1.0"
VFXVER="2024.0.1"

display_jamfHelper() {
    deferral_choice=$(/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -button1 "UPDATE" \
        -timeout 1800 \
        -defaultButton 1 \
        -description "Please close the Maxon applications and update" \
        -windowType utility \
        -title "MAXON APPS UPDATE" \
        -heading "SAVE YOUR WORK" \
        -countdown \
        -alignCountdown right \
        -sound "/System/Library/Sounds/Submarine.aiff" \
        -button2 "Defer")
}

deleteZbrush() {
    pkill -f "ZBrush"
    rm -rf "/Applications/Maxon ZBrush 2024"
}

deferralPopup() {
    userDef=$(osascript -e 'set deferral to {"10 minutes", "30 minutes", "1 hour"}
    set userDef to choose from list deferral with prompt "Select the deferral:" default items {"10 minutes"}')

    echo "User chose $userDef"

    case $userDef in
        "10 minutes") result="600" ;;
        "30 minutes") result="1800" ;;
        "1 hour") result="3600" ;;
        *) echo "Invalid selection"; exit 1 ;;
    esac

    echo "Sleeping for $result seconds"
    sleep "$result"
}

while true; do
    if pgrep -f "ZBrush" >/dev/null; then
        display_jamfHelper
        if [[ $? -eq 0 ]]; then
            deleteZbrush
            break
        else
            deferralPopup
        fi
    else
        deleteZbrush
        break
    fi
done

# Set up logging
log_file="/private/var/tmp/maxonInstall_log.txt"
exec > "$log_file" 2>&1

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S"): $1"
}

#For DMG files
download_and_install() {
    local app_name="$1"
    local app_url="$2"
    local app_loc="${maxonsLoc}/${app_name}.dmg"
    
    log "Downloading $app_name"
    curl "$app_url" --output "$app_loc"
    
    log "Mounting $app_name DMG"
    hdiutil attach "$app_loc" -mountpoint "$mount_point"
    sleep 5
    
    log "Installing $app_name"
    "${maxonsLoc}/Mounted_DMG/${app_name}/Contents/MacOS/installbuilder.sh" --mode unattended --unattendedmodeui none #--skipMaxonAppGui 1
    
    hdiutil detach "$mount_point"
}

mkdir -p /private/var/tmp/Maxons/
mount_point="/private/var/tmp/Maxons/Mounted_DMG"
maxonsLoc="/private/var/tmp/Maxons"
url="https://mx-app-blob-prod.maxon.net/mx-package-production"

download_and_install "Maxon App Installer.app" "${url}/website/macos/maxon/maxonapp/releases/${maxonAppVER}/Maxon_App_${maxonAppVER}_Mac.dmg"
download_and_install "Maxon Cinema 4D Installer.app" "${url}/installer/macos/maxon/cinema4d/releases/${cinema4dVER}/Cinema4D_${cinemaYEAR}_${cinema4dVER}_Mac.dmg"
download_and_install "ZBrush_${zBrushVER}_Installer.app" "${url}/installer/macos/maxon/zbrush/releases/${zBrushVER}/ZBrush_${zBrushVER}_Installer.dmg"

#For PKG files
curl "https://installer.maxon.net/installer/rs/redshift_v${redshiftVER}_macos_metal.pkg" --output "${maxonsLoc}/redshift_v${redshiftVER}_macos_metal.pkg"
installer -verboseR -pkg ${maxonsLoc}/redshift_v${redshiftVER}_macos_metal.pkg -target /

##For ZIP files
download_unzip_and_Install() {
    local app_name="$1"
    local zip_url="$2"
    local zip_loc="${maxonsLoc}/${app_name}.zip"

    log "Downloading $app_name"
    curl "$zip_url" --output "$zip_loc"

    log "Unziping $app_name ZIP"
    unzip "$zip_loc" -d "${maxonsLoc}"

    log "Installing $app_name"
    "${maxonsLoc}/${app_name}/Contents/Scripts/install.sh" #--mode unattended --unattendedmodeui none #--skipMaxonAppGui 1
}

download_unzip_and_Install "Magic Bullet Suite Installer.app" "${url}/installer/macos/redgiant/magicbullet/releases/${magicBulletVER}/MagicBulletSuite-${magicBulletVER}_mac.zip"
download_unzip_and_Install "Trapcode Suite Installer.app" "${url}/installer/macos/redgiant/trapcode/releases/${trapcodeVER}/TrapcodeSuite-${trapcodeVER}_Mac.zip"
download_unzip_and_Install "Universe Installer.app" "${url}/installer/macos/redgiant/universe/releases/${universeVER}/Universe-${universeVER}_Mac.zip"
download_unzip_and_Install "VFX Suite Installer.app" "${url}/installer/macos/redgiant/vfx/releases/${VFXVER}/VfxSuite-${VFXVER}_Mac.zip"

sleep 5
rm -R ${maxonsLoc}
#chflags hidden /Applications/Maxon.app

#SET LOGINS
log "Creating the Login file"
loginEmail="$4"
loginPassword="$5"

cd /Library/Application\ Support/Maxon/Tools/
cat <<EOF > MaxonAppLogin.command
/Library/Application\ Support/Maxon/Tools/mx1 user login -u ${loginEmail} -p ${loginPassword} 
EOF

chown root:wheel /Library/Application\ Support/Maxon/Tools/MaxonAppLogin.command
chmod 455 /Library/Application\ Support/Maxon/Tools/MaxonAppLogin.command
#Hide the file
chflags hidden /Library/Application\ Support/Maxon/Tools/MaxonAppLogin.command

echo "Creating the LaunchAgent"
cd /Library/LaunchAgents/
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.maxon.mxlogin.agent</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/Application Support/Maxon/Tools/MaxonAppLogin.command</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>' > com.maxon.mxlogin.agent.plist

chown root:wheel /Library/LaunchAgents/com.maxon.mxlogin.agent.plist
chmod 444 /Library/LaunchAgents/com.maxon.mxlogin.agent.plist

exit 0

###########################
# C4D removal for upgrade #
###########################

# Remove the Cinema 4D and preferences. Specify the year.
#for userName in `ls /Users | grep -v Shared`
#do
#    if [ -d /Applications/Maxon\ Cinema\ 4D\ 2023/  ]
#        then 
#        echo "Removing Ciema 4D 2023"
#        rm -rf "/Applications/Maxon Cinema 4D 2023/"
#        rm -rf "/Users/$userName/Library/Preferences/Maxon/"
#    else
#        echo "Cinema 4D 2023 is not installed"
#    fi
#done
