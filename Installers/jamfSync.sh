#!/bin/bash

# Collect the latest version here https://github.com/jamf/JamfSync

jamfSyncVer="1.4.0"
mkdir -p /private/var/tmp/jamfSync/
jamfSyncLoc="/private/var/tmp/jamfSync"
url="https://github.com/jamf/JamfSync/releases/download/${jamfSyncVer}/Jamf.Sync.app.zip"

download_and_unzip() {
    local zip_url="$1"
    local zip_loc="${jamfSyncLoc}/Jamf.Sync.app.zip"

    curl -L "$zip_url" --output "$zip_loc"
    unzip -o "$zip_loc" -d "${jamfSyncLoc}"
}
 
move_and_cleanup() {
    local source_dir="${jamfSyncLoc}/Jamf Sync.app"
    local dest_dir="/Applications"

    mv "$source_dir" "$dest_dir"
    rm -rf "$jamfSyncLoc"
}

download_and_unzip "${url}"
move_and_cleanup

exit 0
