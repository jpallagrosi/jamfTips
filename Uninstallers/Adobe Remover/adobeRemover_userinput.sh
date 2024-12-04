#!/bin/bash

# This will present the user with the list of Adobe installed applications.
adobeApps=()
for dir in /Applications/Adobe*; do
    if [ -d "$dir" ]; then
        appName=$(basename "$dir")
        adobeApps+=("$appName")
    fi
done

appList=$(printf "\"%s\", " "${adobeApps[@]}")
appList=${appList%, } 

APP_NAME=$(osascript -e "set appToBeRemoved to {$appList}
set appName to choose from list appToBeRemoved with prompt \"Select the application to be removed:\" ")

if [ "$APP_NAME" = "false" ] || [ -z "$APP_NAME" ]; then
    echo "No application selected. Exiting."
    exit 0
fi

echo "Script started. Removing $APP_NAME"

if pgrep -f "$APP_NAME" > /dev/null; then
    echo "$APP_NAME is running."
    osascript -e "display dialog \"Please save your work and close $APP_NAME\" & return & \"This will remove the application.\" buttons {\"OK\"} default button 1"
    echo "Killing $APP_NAME process."
    pkill -f "$APP_NAME"
    sleep 2
fi

appPath="/Applications/$APP_NAME"
if [ -d "$appPath" ]; then
    echo "Removing $APP_NAME from /Applications directory."
    rm -rf "$appPath"
    echo "$APP_NAME has been removed."
else
    echo "$APP_NAME not found in /Applications."
fi

exit 0
