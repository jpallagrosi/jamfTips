#!/bin/bash

scriptPath=$(osascript -e 'text returned of (display dialog "Current location of the script to be automated" default answer "")')
deploymentScriptName=$(osascript -e 'text returned of (display dialog "Enter the Deployment script name without the .sh: " default answer "")')
deploymentScriptLoc=$(osascript -e 'text returned of (display dialog "Confirm the location of the Deployment script: " default answer "/Users/Shared")')
scriptName=$(osascript -e 'text returned of (display dialog "Enter the name of the script to be automated without .sh: " default answer "")')
scriptLoc=$(osascript -e 'text returned of (display dialog "Confirm the location of '$scriptName'.sh on the client machine: " default answer "/Library/Scripts")')

launchType=$(osascript -e 'choose from list {"LaunchAgent", "LaunchDaemon"} with title "Select Launch Type" default items {"LaunchAgent"}')
if [[ "$launchType" == "LaunchAgent" ]]; then
    launchDir="/Library/LaunchAgents"
else
    launchDir="/Library/LaunchDaemons"
fi

launchName=$(osascript -e 'text returned of (display dialog "Enter the LaunchAgent or Daemon name without the com. and .plist: " default answer "")')

echo '#!/bin/bash

cd '"$scriptLoc"'

tee <<EOF > "'${scriptName}'.sh"

EOF

chmod +x '"$scriptLoc"'/'"${scriptName}.sh"'

cd '"$launchDir"' || exit 1

tee <<EOF > "com.'"${launchName}"'.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>'${launchName}'</string>
    <key>ProgramArguments</key>
    <array>
        <string>'$scriptLoc'/'${scriptName}'.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

chown root:wheel "com.'"${launchName}"'.plist"
chmod 644 "com.'"${launchName}"'.plist"

launchctl bootstrap system "com.'"${launchName}"'.plist"

exit 0' > "$deploymentScriptLoc/$deploymentScriptName.sh"

finalScript="$deploymentScriptLoc/$deploymentScriptName.sh"

scriptContent=$(cat "$scriptPath")
sed -i '' '6r /dev/stdin' "$finalScript" <<< "$scriptContent"
chmod +x $finalScript
