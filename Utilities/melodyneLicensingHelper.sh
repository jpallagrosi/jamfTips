#!/bin/bash

MELODYNE_APP="/Applications/Melodyne 5/Melodyne.app"

AUTH_CODE="$4"
EMAIL="$5"

loggedInUser=$(stat -f %Su /dev/console)

if [[ ! -d "$MELODYNE_APP" ]]; then
    echo "Melodyne app not found."
    exit 1
fi

if [[ -z "$AUTH_CODE" || -z "$EMAIL" ]]; then
    echo "Missing Parameter 4 (Auth Code) or Parameter 5 (Email)."
    exit 1
fi

echo "Launching Melodyne..."

sudo -u "$loggedInUser" open "$MELODYNE_APP"

sleep 5

response=$(sudo -u "$loggedInUser" osascript <<EOF
display dialog "This helper will launch Melodyne.

Please copy and paste the authorisation code and the email.

You will need to enter the password manually.

Only close Melodyne once licensing is complete.


Authorisation Code:
$AUTH_CODE

Email:
$EMAIL" buttons {"Close Melodyne","OK"} default button "OK" with title "Melodyne Licensing Helper"
button returned of result
EOF
)

if [[ "$response" == "Close Melodyne" ]]; then

    echo "Closing Melodyne..."

    pkill -x "Melodyne"

fi

exit 0