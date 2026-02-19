#!/bin/bash

currentHour=$(date +%H)

if [ "$currentHour" -ge 5 ]; then
    exit 0
fi

delay=$(( RANDOM % 10800 ))
sleep "$delay"