#!/bin/sh

addOnLoc="/Library/Application Support/Adobe/Premiere Pro"
addOnYear="$4"
addOnFinalLoc="$addOnLoc/$addOnYear.0/SpeechESL/2.1.6_b31d91e1d8_esl"

addOnName=""
for dir in "$addOnLoc"/*; do
    dir_name=$(basename "$dir")
    if [ -d "$dir" ] && [[ ! "$dir_name" =~ [0-9] ]] && [ "$dir_name" != "PLACEHOLDER" ]; then
        addOnName="$dir_name"
        break
    fi
done

if [ -d "$addOnFinalLoc" ]; then
    echo "Copying ${addOnLoc}/${addOnName} to $addOnFinalLoc"
    mv "${addOnLoc}/${addOnName}" "$addOnFinalLoc"
    echo "Removing ${addOnLoc}/PLACEHOLDER"
    rm -rf "${addOnLoc}/PLACEHOLDER"
else
    echo "Renaming ${addOnLoc}/PLACEHOLDER to ${addOnLoc}/${addOnYear}.0"
    mv "${addOnLoc}/PLACEHOLDER" "${addOnLoc}/${addOnYear}.0"
    echo "Copying ${addOnLoc}/${addOnName} to $addOnFinalLoc"
    mv "${addOnLoc}/${addOnName}" "$addOnFinalLoc"
fi

exit 0
