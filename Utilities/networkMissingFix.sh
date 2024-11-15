#!/bin/bash

# In the instance of a Network dropping out of the list of known network you can re add it by removing and re installing the configuration profile.
# Just need to creat a static group and place it as eclusion in the network Configuration Profile.
# Check EA here github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/EA/networkCheck.sh to target the affected Macs only.

clientID=""
clientSecret="$4" # Policy parameter
jamfProURL=""
groupID="" # Static group from the exclusion
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')
targetNetwork=""
maxAttempts=5
attempt=0 

getAccessToken() {
  request=$(curl -s \
  --request POST "$jamfProURL/api/oauth/token" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "client_id=$clientID" \
  --data-urlencode 'grant_type=client_credentials' \
  --data-urlencode "client_secret=$clientSecret")
  
  access_token=$(echo "$request" | plutil -extract access_token raw -)
  token_expires_in=$(echo "$request" | plutil -extract expires_in raw -)
  current_epoch=$(date +%s)
  token_expiration_epoch=$(($current_epoch + $token_expires_in))
}

getComputerID() {
    computerID=$(curl -s \
-H "Authorization: Bearer $access_token" \
-H "Accept: application/xml" \
"$jamfProURL/JSSResource/computers/serialnumber/$serialNumber" | \
xmllint --xpath '/computer/general/id/text()' -)
}

addComputerToGroup() {
curl -s \
-H "Authorization: Bearer $access_token" \
-H "Content-Type: application/xml" \
-X PUT "$jamfProURL/JSSResource/computergroups/id/$groupID" \
-d "<computer_group><computer_additions><computer><id>$computerID</id></computer></computer_additions></computer_group>"
}

removeComputerFromGroup() {
curl -s \
-H "Authorization: Bearer $access_token" \
-H "Content-Type: application/xml" \
-X PUT "$jamfProURL/JSSResource/computergroups/id/$groupID" \
-d "<computer_group><computer_deletions><computer><id>$computerID</id></computer></computer_deletions></computer_group>"
}

getAccessToken
getComputerID

while [[ $attempt -lt $maxAttempts ]]; do
    ((attempt++))
    echo "Attempt $attempt of $maxAttempts..."
    addComputerToGroup
    sleep 10
    jamf recon
    removeComputerFromGroup
    sleep 10
    jamf recon

    wifiDevice=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}' ) 
    knownNetworks=$(networksetup -listpreferredwirelessnetworks $wifiDevice)

    if echo "$knownNetworks" | grep -q "$targetNetwork"; then
        echo "Network $targetNetwork is in the list of known networks."
        exit 0  
    else
        echo "Network $targetNetwork not found. Retrying..."
    fi
    if [[ $attempt -ge $maxAttempts ]]; then
        echo "Reached maximum number of attempts ($maxAttempts). Exiting."
        exit 1
    fi
done
