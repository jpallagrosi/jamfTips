#!/bin/bash

#######################################################################################################################
# Inception Script: Automate deployment workflows with LaunchAgents/LaunchDaemons
# Author: jpallagrosi | Last Updated: 24/04/24
# More info: https://github.com/jpallagrosi/jamfUsefulScripts/tree/WIP/Utilities/Inception
#######################################################################################################################

collectInfo() {
    echo "Collecting user input..."
    scriptPath=$(osascript -e 'text returned of (display dialog "Current location of the script to be automated" default answer "")')
    deploymentScriptName=$(osascript -e 'text returned of (display dialog "Enter the Deployment script name without the .sh: " default answer "")')
    deploymentScriptLoc=$(osascript -e 'text returned of (display dialog "Confirm the location of the Deployment script: " default answer "/Users/Shared")')
    scriptName=$(osascript -e 'text returned of (display dialog "Enter the name of the script to be automated without .sh: " default answer "")')
    scriptLoc=$(osascript -e 'text returned of (display dialog "Confirm the location of '$scriptName'.sh on the client machine: " default answer "/Library/Scripts")')

    launchType=$(osascript -e 'choose from list {"LaunchAgent", "LaunchDaemon"} with title "Select Launch Type" default items {"LaunchAgent"}')
    launchDir="/Library/${launchType}s"

    launchName=$(osascript -e 'text returned of (display dialog "Enter the LaunchAgent or Daemon name without the com. and .plist: " default answer "")')
}

validateInputs() {
    echo "Validating inputs..."
    if [[ ! -f "$scriptPath" ]]; then
        echo "Error: The script at $scriptPath does not exist."
        exit 1
    fi
    if [[ ! -d "$deploymentScriptLoc" ]]; then
        echo "Error: The directory $deploymentScriptLoc does not exist."
        exit 1
    fi
    if [[ ! -d "$scriptLoc" ]]; then
        echo "Error: The directory $scriptLoc does not exist."
        exit 1
    fi
}

buildWorkflow() {
    echo "Building the workflow..."
    finalScript="$deploymentScriptLoc/$deploymentScriptName.sh"

    cat <<EOF > "$finalScript"
#!/bin/bash

cd "$scriptLoc"

cat <<'SCRIPT' > "${scriptName}.sh"
$(cat "$scriptPath")
SCRIPT

chmod +x "${scriptName}.sh"

cat <<'PLIST' > "$launchDir/com.${launchName}.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.${launchName}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${scriptLoc}/${scriptName}.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST

chmod 644 "$launchDir/com.${launchName}.plist"
chown root:wheel "$launchDir/com.${launchName}.plist"
EOF

    chmod +x "$finalScript"
    echo "Workflow created successfully at $finalScript"
}

testRun() {
    echo "Testing the deployment script..."
    local choice=$(osascript -e 'button returned of (display dialog "Click Yes to run the Deployment script." buttons {"No", "Yes"} default button 1)')
    if [[ "$choice" == "Yes" ]]; then
        sudo "$finalScript"
    else
        echo "Test run skipped."
    fi
}

# EXECUTION
collectInfo
validateInputs
buildWorkflow
testRun

exit 0
