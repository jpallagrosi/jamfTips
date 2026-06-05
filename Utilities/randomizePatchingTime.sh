#!/bin/bash

#This tool helps deployments with low internet speed.
currentHour=$(date +%H)

if [ "$currentHour" -ge 5 ]; then
    exit 0
fi

delay=$(( RANDOM % 10800 ))
sleep "$delay"