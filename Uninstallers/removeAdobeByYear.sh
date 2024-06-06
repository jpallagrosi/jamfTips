#!/bin/bash

# Set the year to remove in Parameter 4.
yearToRemove="$4"

applications=(
    "Adobe After Effects"
    "Adobe Animate"
    "Adobe Audition"
    "Adobe Bridge"
    "Adobe Character Animator"
    "Adobe Illustrator"
    "Adobe InCopy"
    "Adobe InDesign"
    "Adobe Media Encoder"
    "Adobe Photoshop"
    "Adobe Prelude"
    "Adobe Premiere Pro"
)

removeDirectories() {
    for app in "${applications[@]}"; do
        fullPath="/Applications/${app} ${yearToRemove}"
        if [ -d "$fullPath" ]; then
            rm -R "$fullPath"
            if [ $? -eq 0 ]; then
                echo "Removed: $fullPath"
            else
                echo "Failed to remove: $fullPath"
            fi
        else
            echo "Directory does not exist: $fullPath"
        fi
    done
}

checkDirectories() {
    allRemoved=true
    for app in "${applications[@]}"; do
        fullPath="/Applications/${app} ${yearToRemove}"
        if [ -d "$fullPath" ]; then
            echo "Directory still exists: $fullPath"
            allRemoved=false
        fi
    done
    $allRemoved
}

removeDirectories

max_attempts=5
attempt=1
while [ $attempt -le $max_attempts ]; do
    if checkDirectories; then
        break
    else
        removeDirectories
        attempt=$((attempt + 1))
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Maximum attempts reached. Some directories could not be removed."
fi

exit 0


################################################################################################
# THIS SECTION IS FOR TESTING PURPOSES ONLY.                                                   #
# Often two years old Adobe packages stop working.                                             #
# However the name is the same with just an older year.                                        #
# Install the latest packages and run the below to change the year.                            #
# Double check if Adobe didn't change the naming convention in the latest year.                #
# Run separtely/locally before deleting the apps.                                              #
################################################################################################

# #!/bin/bash
# yearToChange=""
# yearToTest=""
# cd /Applications/

# for apps in *$yearToChange; do
#    newName="${apps%$yearToChange}"
#    newName="${newName}${yearToTest}"

#    oldFullPath="/Applications/${apps}"
#    newFullPath="/Applications/${newName}"

#    mv "$oldFullPath" "$newFullPath"
# done
