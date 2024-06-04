#!/bin/bash

# This section before the curl is for patching or re installing
removeCounters() {
for userName in `ls /Users | grep -v Shared`
	do
	rm -f /Users/$userName/Library/Counters/mailToOutlookCounter
done
}

if [ -f /Users/$3/Library/Counters/mailToOutlookCounter ]
	then 
	echo "Removing counters"
        removeCounters
fi

# Double check the version in the URL
curl https://macadmins.software/tools/MailToOutlook_2.1.pkg --output /usr/local/MailToOutlook_2.1.pkg

script="runMailToOutlook.sh"
scriptLoc="/Library/Scripts"
launchAgent="com.mailtooutlook.runpackage.plist"
launchAgentLoc="/Library/LaunchAgents"

cd "$scriptLoc"

tee <<'EOF' > "$script"
#!/bin/bash

loggedInUser=$(stat -f "%Su" /dev/console)
counterFolder="/Users/$loggedInUser/Library/Counters"
counterFile="/Users/$loggedInUser/Library/Counters/mailToOutlookCounter"
PKG="/usr/local/MailToOutlook_2.1.pkg"

if [ ! -d "$counterFolder" ]; then
    mkdir -p "/Users/$loggedInUser/Library/Counters"
else
    echo "Counter folder is already there"
fi


if [ ! -f "$counterFile" ]; then
    echo "1" > "$counterFile"
fi
counter=$(<"$counterFile")

if [ ! -f "$PKG" ]; then
    echo "Package file not found: $PKG"
    exit 1
fi

if [ "$counter" -gt 1 ]; then
    echo "Script has already run for this user. Exiting."
    exit 0
fi

((counter++))
echo "$counter" > "$counterFile"

echo "Installing package: $PKG"
installer -pkg "$PKG" -target /
EOF

chmod +x "$script"

cd "$launchAgentLoc" || exit

tee <<EOF > "$launchAgent"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mailtooutlook.runpackage</string>
    <key>ProgramArguments</key>
    <array>
        <string>$scriptLoc/$script</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

chown root:wheel $launchAgent
chmod 644 "$launchAgent"

launchctl bootstrap system "$launchAgent"

exit 0
