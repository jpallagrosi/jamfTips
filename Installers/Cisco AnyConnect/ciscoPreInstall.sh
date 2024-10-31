#!/bin/bash

packageSource="/usr/local/Cisco Secure Client.pkg"
expandedDirectory="/usr/local/VPN"
linesToRemove="9,17d"
fileToAppend="/usr/local/VPN/Distribution"
installerPath="/usr/local/VPN.pkg"
countExpected="2"
maxAttempts=5
attempt=0 

display_jamfHelper() {
    deferral_choice=$(/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper \
        -button1 "UPDATE" \
        -timeout 900 \
        -defaultButton 1 \
        -description "The Cisco VPN will disconnect during the installation process. Please save your work and log back in once the installation is complete." \
        -windowType utility \
        -icon "/Library/Application Support/JAMF/CiscoInstall.png" \
        -title "Cisco AnyConnect Update" \
        -countdown \
        -alignCountdown right \
        -sound "/System/Library/Sounds/Submarine.aiff" \
        -button2 "Defer")        
}

deferralPopup() {
    userDef=$(osascript -e 'set deferral to {"10 minutes", "30 minutes", "1 hour"}
    set userDef to choose from list deferral with title "Cisco AnyConnect Update" with prompt "Select the deferral:" default items {"10 minutes"}')

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

installCisco() {
        pkgutil --expand "$packageSource" "$expandedDirectory"
		sed -i.bak "$linesToRemove" "$fileToAppend"
		rm "/usr/local/VPN/Distribution.bak"

		pkgutil --flatten "$expandedDirectory" "$installerPath"
		installer -verboseR -pkg "$installerPath" -target /

		rm "$packageSource"
		rm -r "$expandedDirectory"
		rm "$installerPath"
}

while true; do
    process_count=$(pgrep -fl "Cisco Secure Client" | wc -l) 
    if [[ "$process_count" -eq $countExpected ]]; then
        while [[ $attempt -lt $maxAttempts ]]; do
            display_jamfHelper
            if [[ $? -eq 0 ]]; then
                installCisco
                break
            else
                ((attempt++))
                echo "Attempt $attempt of $maxAttempts..."
                deferralPopup
            fi
        done
        if [[ $attempt -ge $maxAttempts ]]; then
            echo "Max deferral attempts reached. Exiting..."
            exit 1
        fi
    else
        installCisco
        break
    fi
done

exit 0
