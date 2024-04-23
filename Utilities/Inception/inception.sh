#!/bin/bash

#######################################################################################################################
# inception script will help you build an automated workflow #
# jpallagrosi 24/04/24 # More info here https://github.com/jpallagrosi/jamfUsefulScripts/tree/WIP/Utilities/Inception #
#######################################################################################################################

collectInfo() {
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
}

#####################################################################################################################################################################

buildWorkflow() {
echo '#!/bin/bash

cd '"$scriptLoc"'

tee <<'"'EOF'"' > "'${scriptName}'.sh"

EOF

chmod +x '"$scriptLoc"'/'"${scriptName}.sh"'

cd '"$launchDir"' || exit 1

tee <<'EOF' > "com.'"${launchName}"'.plist"
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

# launchctl bootstrap system "com.'"${launchName}"'.plist"

exit 0' > "$deploymentScriptLoc/$deploymentScriptName.sh"

finalScript="$deploymentScriptLoc/$deploymentScriptName.sh"

scriptContent=$(cat "$scriptPath")
sed -i '' '6r /dev/stdin' "$finalScript" <<< "$scriptContent"
chmod +x $finalScript
}

#####################################################################################################################################################################

collectInfo

buildWorkflow

testRun=$(osascript -e 'button returned of (display dialog "Click Yes to run the Deployment script." buttons {"No", "Yes"} default button 1)')

if [ "$testRun" == "Yes" ]; then
	sudo "$deploymentScriptLoc/./$deploymentScriptName.sh"
    exit 0
else
	exit 0
fi

# -|> #
