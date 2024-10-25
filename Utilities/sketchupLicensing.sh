#!/bin/sh

# JPallagropsi 2024
# This will remove the previous year and license the new year

sketchupYear="$4"  # Parameter 4
serialNumber="$5"  # Parameter 5
authCode="$6"      # Parameter 6

previousYear=$((sketchupYear - 1))
licenseLoc="/Library/Application Support/SketchUp ${sketchupYear}"
licenseFile="activation_info.txt"

if [ -d "/Applications/SketchUp ${previousYear}" ]; then
    echo "Removing ${previousYear} license file and creating ${sketchupYear}"
    rm -R "/Applications/SketchUp ${previousYear}"
    rm -R "/Library/Application Support/SketchUp ${previousYear}"
    for user in $(ls /Users | grep -v Shared); do
        rm -rf "/Users/$user/Library/Application Support/SketchUp $previousYear"
    done
else
    echo "Creating ${sketchupYear} license file."
fi

mkdir -p "$licenseLoc"
cd "$licenseLoc" || exit 1

cat <<EOF > "${licenseFile}"
{
    "serial_number": "${serialNumber}",
    "auth_code": "${authCode}"
}
EOF

chown root:wheel "$licenseFile"
chmod 775 "$licenseFile"

#Helper
mkdir -p "/Library/Application Support/Reprise"

#Quarantine
for app in "/Applications/SketchUp ${sketchupYear}"/*.app; do
    xattr -r -d com.apple.quarantine "$app"
done

exit 0
