#!/bin/bash

targetNetwork="" # Affected network
wifiDevice=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}' ) 
knownNetworks=$(networksetup -listpreferredwirelessnetworks $wifiDevice)

if echo "$knownNetworks" | grep -q "$targetNetwork"; then
    networkStatus="Present"
else
    networkStatus="Not Present"
fi

echo "<result>$networkStatus</result>"
