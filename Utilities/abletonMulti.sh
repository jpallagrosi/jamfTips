#!/bin/sh

# JPallagropsi 2024

abletonPath="/Applications/Ableton Live 11 Suite.app"
localAccount=""
loggedInUser=$(ls -l /dev/console | awk '{print $3}')
licenseFileDir="/Users/${localAccount}/Library/Application Support/Ableton/"

if [ "$loggedInUser" != "$localAccount" ]; then
    echo "Please log in as $localAccount"
    exit 1
fi

if [ ! -d "$abletonPath" ]; then
    echo "Ableton is not installed"
    exit 1
fi

open "$abletonPath"

until [ -d "$licenseFileDir" ]; do
    echo "Waiting for license file..."
    sleep 2
done
sleep 2

abletonVer=$(ls "$licenseFileDir" 2>/dev/null | grep "Live " | head -n 1 | awk '{print $2}')
if [ -z "$abletonVer" ]; then
    echo "Unable to find the Ableton Live version. Please check the installation."
    exit 1
fi

if [ -f "/Library/Application Support/Ableton/Live $abletonVer/Unlock/Unlock.cfg" ]; then
    echo "Ableton has already been licensed for multiple users."
    pkill Live
    sleep 5
    exit 1
else
	sleep 4
    osascript -e 'display dialog "Please Allow access to the microphone. Click Authorise and login to ableton.com. Allow communication to Ableton Live and click OK. Allow access to the Documents folder. ONLY CLICK DONE AFTER LICENSING!" buttons {"DONE"} default button 1'
    sleep 2
    pkill Live
fi

echo "Waiting for Ableton Live to close..."
while pgrep -x "Live" > /dev/null; do
    sleep 2
done
echo "Ableton Live is now closed."
echo "Ableton Live $abletonVer is not running. Proceeding with the script."

cp "/Users/${localAccount}/Library/Application Support/Ableton/Live $abletonVer/Unlock/Unlock.cfg" "/Library/Application Support/Ableton/Live $abletonVer/Unlock/"
rm -rf "/Users/${localAccount}/Library/Application Support/Ableton/Live $abletonVer/"
rm -rf "/Users/${localAccount}/Library/Preferences/Ableton/Live $abletonVer"

echo "ALL DONE"
exit 0
