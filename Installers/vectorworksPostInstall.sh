#!/bin/bash

# Package up and deploy the DMG installer in the shared folder. Also double check the variables.
yearToRemove="2023"
yearToInstall="2024"
server="" # The organisation server
serialNumber="" # The organisation license
dmgName="Vectorworks2024-SP5-757604-SeriesBEG-installer2-osx"
fileLocation="/Applications/Vectorworks ${yearToInstall}/Settings/SeriesG/"
fileName="LoginDialog.xml"

# Running this function works better in a separate policy as it is more effective with a restart
removePreVer() {
if [ -d "/Applications/Vectorworks ${yearToRemove}" ]; then
    architecture=$(uname -m)

   if [ "$architecture" = "x86_64" ]; then
            arch="osx-x86_64"
        elif [ "$architecture" = "arm64" ]; then
            arch="osx-arm64"
        else
            echo "Unsupported architecture: $architecture"
            exit 1
        fi

    sudo /Applications/Vectorworks\ ${yearToRemove}/Uninstall.app/Contents/MacOS/$arch --mode unattended
    rm -rf "/Applications/Vectorworks ${yearToRemove}"

    echo "Vectorworks ${yearToRemove} has been uninstalled."
else
    echo "Vectorworks ${yearToRemove} is not installed."
fi
}

runPackage() {
hdiutil attach /Users/Shared/${dmgName}.dmg
  
sudo /Volumes/${dmgName}/Vectorworks\ ${yearToInstall}\ Installer.app/Contents/Resources/installer/Install\ Vectorworks${yearToInstall}.app/Contents/MacOS/installbuilder.sh --unattendedmodeui none --mode unattended --Serial $serialNumber --installdir "/Applications/Vectorworks 2024" --sysUsername its --LDFChoice licenseID

diskutil unmount /Volumes/${dmgName}

sleep 15s

rm /Users/Shared/${dmgName}.dmg
}

creatingSettingsfile() {
sudo mkdir -p "$fileLocation"
cd "$fileLocation"

tee <<EOF > "${fileName}"
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<LoginDialog>

  <Days>1</Days>

  <AutoFindServer>0</AutoFindServer>

  <AutoFindMaxTime>1</AutoFindMaxTime>

  <DontShowAtStartup>1</DontShowAtStartup>

  <Servers>
    <Server>${server}</Server>
  </Servers>

  <Modules>
    <MainModule>designer</MainModule>
  </Modules>

</LoginDialog>" | sudo tee "$fileName" > /dev/null

sudo chown root:wheel "${fileLocation}${fileName}"
sudo chmod 775 "${fileLocation}${fileName}"
EOF
}

#removePreVer
sleep 10
runPackage
creatingSettingsfile

exit 0
