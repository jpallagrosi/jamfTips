#!/bin/bash
set -euo pipefail

############################
# FabFilter Jamf Installer #
############################

############################################
# -------- CONFIGURATION SECTION -------- #
############################################

# ---- LICENSE (CHANGE PER SITE) ----
licenseCode=""

# Parameter 4 = comma separated products NOT to install
SKIP_LIST="${4:-}"

# Logging
log_file="/private/var/tmp/fabfilterInstall_log.txt"
exec > "$log_file" 2>&1

log() {
    echo "$(date "+%Y-%m-%d %H:%M:%S"): $1"
}

log "Starting FabFilter installation..."
log "Skip list: $SKIP_LIST"

############################################
# -------- WORKING DIRECTORIES ----------- #
############################################

WORKDIR="/private/var/tmp/FabFilter"
MOUNT_POINT="$WORKDIR/mount"
PLIST_LOC="/Library/Preferences"

mkdir -p "$WORKDIR"
mkdir -p "$MOUNT_POINT"
mkdir -p "$PLIST_LOC"

#################################
# FabFilter Product Definitions #
#################################

products=(
"pro-q 4|https://cdn-b.fabfilter.com/downloads/ffproq410.dmg"
"pro-c 3|https://cdn-b.fabfilter.com/downloads/ffproc300.dmg"
"pro-l 3|https://cdn-b.fabfilter.com/downloads/ffprol224.dmg"
"pro-r 2|https://cdn-b.fabfilter.com/downloads/ffpror204.dmg"
"pro-mb|https://cdn-b.fabfilter.com/downloads/ffpromb131.dmg"
"pro-ds|https://cdn-b.fabfilter.com/downloads/ffprods130.dmg"
"pro-g|https://cdn-b.fabfilter.com/downloads/ffprog140.dmg"
"saturn 2|https://cdn-b.fabfilter.com/downloads/ffsaturn211.dmg"
"timeless 3|https://cdn-b.fabfilter.com/downloads/fftimeless308.dmg"
"twin 3|https://cdn-b.fabfilter.com/downloads/fftwin305.dmg"
"one|https://cdn-b.fabfilter.com/downloads/ffone350.dmg"
"simplon|https://cdn-b.fabfilter.com/downloads/ffsimplon140.dmg"
"micro|https://cdn-b.fabfilter.com/downloads/ffmicro130.dmg"
)

#################################
# Skip Check
#################################

should_skip() {
    product="$1"
    echo "$SKIP_LIST" | tr ',' '\n' | grep -iq "^$product$"
}

#################################
# Install Function
#################################

install_product() {

    NAME="$1"
    URL="$2"
    DMG="$WORKDIR/${NAME}.dmg"

    log "Downloading $NAME"
    curl -L "$URL" -o "$DMG"

    log "Mounting $NAME"
    hdiutil attach "$DMG" -mountpoint "$MOUNT_POINT" -nobrowse -quiet

    PKG=$(find "$MOUNT_POINT" -name "*.pkg" | head -1)

    if [[ -z "$PKG" ]]; then
        log "No pkg found for $NAME"
        hdiutil detach "$MOUNT_POINT" -quiet
        return
    fi

    log "Installing $NAME"
    /usr/sbin/installer -pkg "$PKG" -target /

    hdiutil detach "$MOUNT_POINT" -quiet
    rm -f "$DMG"

    log "$NAME installed successfully"
}

#################################
# Installation Loop
#################################

for item in "${products[@]}"
do
    NAME=$(echo "$item" | cut -d '|' -f1)
    URL=$(echo "$item" | cut -d '|' -f2)

    if should_skip "$NAME"; then
        log "Skipping $NAME"
        continue
    fi

    install_product "$NAME" "$URL"
done

log "Plugin installation phase complete."

############################################
# -------- LICENSE DEPLOYMENT ------------ #
############################################

log "Writing FabFilter license plists..."

write_plist() {
    local plistName="$1"
    local plistPath="$PLIST_LOC/$plistName"

    cat > "$plistPath"

    chmod 644 "$plistPath"
    chown root:wheel "$plistPath"

    log "Created $plistName"
}

############################################################
# ------------- KEEP ALL 14 PLISTS BELOW ----------------- #
# ------------- DO NOT MERGE OR MODIFY -------------------- #
############################################################

# -------------------------
# Micro
# -------------------------
write_plist "com.fabfilter.Micro.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CorrectDigiProductIds</key>
	<integer>0</integer>
	<key>CurrentVersion</key>
	<string>1.30</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>LicenseError</key>
	<string></string>
	<key>LicenseText</key>
	<string>$licenseCode</string>
	<key>PresetBrowserTypeToSearch</key>
	<integer>1</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Micro/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ScalingAdjustments</key>
	<string></string>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# One
# -------------------------
write_plist "com.fabfilter.One.3.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>3.35</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/One/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-C 2
# -------------------------
write_plist "com.fabfilter.Pro-C.2.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>2.15</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>346</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>InterfacePanels</key>
	<integer>0</integer>
	<key>InterfaceWidth</key>
	<integer>680</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-C 2/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-DS
# -------------------------
write_plist "com.fabfilter.Pro-DS.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>1.19</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfacePanels</key>
	<integer>1</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-DS/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-G
# -------------------------
write_plist "com.fabfilter.Pro-G.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>1.29</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfacePanels</key>
	<integer>0</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-G/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-L 2
# -------------------------
write_plist "com.fabfilter.Pro-L.2.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>2.11</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>480</integer>
	<key>InterfaceLayout</key>
	<integer>2</integer>
	<key>InterfaceWidth</key>
	<integer>800</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-L 2/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-MB
# -------------------------
write_plist "com.fabfilter.Pro-MB.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AutoAdjustDisplayRange</key>
	<integer>1</integer>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>1.26</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>584</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>InterfaceWidth</key>
	<integer>900</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-MB/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-Q 3
# -------------------------
write_plist "com.fabfilter.Pro-Q.3.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AutoAdjustDisplayRange</key>
	<integer>1</integer>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CurrentVersion</key>
	<string>3.21</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GainQInteraction</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>335</integer>
	<key>InterfaceLayout</key>
	<integer>2</integer>
	<key>InterfaceWidth</key>
	<integer>720</integer>
	<key>PianoRoll</key>
	<integer>0</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-Q 3/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>ShowMouseFrequency</key>
	<integer>1</integer>
	<key>ShowOutputLevelMeter</key>
	<integer>1</integer>
	<key>UseAccessibleColors</key>
	<integer>0</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Pro-R
# -------------------------
write_plist "com.fabfilter.Pro-R.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>1.13</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>600</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>InterfaceWidth</key>
	<integer>850</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Pro-R/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Saturn 2
# -------------------------
write_plist "com.fabfilter.Saturn.2.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CurrentVersion</key>
	<string>2.06</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>450</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>InterfaceWidth</key>
	<integer>800</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Saturn 2/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>ShowSources</key>
	<integer>0</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Simplon
# -------------------------
write_plist "com.fabfilter.Simplon.1.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>1.34</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Simplon/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Timeless 3
# -------------------------
write_plist "com.fabfilter.Timeless.3.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CurrentVersion</key>
	<string>3.03</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>450</integer>
	<key>InterfaceLayout</key>
	<integer>1</integer>
	<key>InterfaceWidth</key>
	<integer>800</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Timeless 3/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>ShowSources</key>
	<integer>0</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Twin 2
# -------------------------
write_plist "com.fabfilter.Twin.2.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CorrectDigiProductIds</key>
	<integer>1</integer>
	<key>CurrentVersion</key>
	<string>2.34</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>ExpandedSection</key>
	<integer>-1</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Twin 2/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>ShowModulation</key>
	<integer>0</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# -------------------------
# Volcano 3
# -------------------------
write_plist "com.fabfilter.Volcano.3.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BundleLicenseText</key>
	<string>$licenseCode</string>
	<key>CurrentVersion</key>
	<string>3.02</string>
	<key>EnableMIDIProgramChanges</key>
	<integer>0</integer>
	<key>GraphicsAcceleration</key>
	<integer>1</integer>
	<key>InterfaceHeight</key>
	<integer>450</integer>
	<key>InterfaceLayout</key>
	<integer>0</integer>
	<key>InterfaceWidth</key>
	<integer>800</integer>
	<key>PianoDisplay</key>
	<integer>0</integer>
	<key>PresetFolder</key>
	<string>/Users/music/Documents/FabFilter/Presets/Volcano 3/</string>
	<key>RetinaEnabled</key>
	<integer>1</integer>
	<key>SavePresetItemEnabled</key>
	<integer>0</integer>
	<key>ShowComponentDisplays</key>
	<integer>1</integer>
	<key>showInteractiveHelp</key>
	<integer>1</integer>
	<key>showWelcomeHint</key>
	<integer>1</integer>
</dict>
</plist>
EOF

log "All FabFilter plist files written successfully."
log "FabFilter installation complete."

# Optional cleanup
rm -rf "$WORKDIR"

exit 0
