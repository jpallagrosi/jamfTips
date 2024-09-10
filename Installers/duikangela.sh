#!/bin/bash

# Collect the latest version here https://github.com/RxLaboratory/Duik/releases

duikAngelaVer="17.1.16"
mkdir -p /private/var/tmp/Duik/
duikLoc="/private/var/tmp/Duik"
url="https://github.com/RxLaboratory/Duik/releases/download/v${duikAngelaVer}/Duik_Angela_${duikAngelaVer}.zip"

download_and_unzip() {
    local zip_url="$1"
    local zip_loc="${duikLoc}/Duik_Angela_${duikAngelaVer}.zip"

    curl -L "$zip_url" --output "$zip_loc"
    unzip "$zip_loc" -d "${duikLoc}"
}

move_and_cleanup() {
    local source_dir="${duikLoc}/Scripts/ScriptUI Panels"
    local dest_dir="/Applications/Adobe After Effects 2024/Scripts/ScriptUI Panels"

	sudo mv "$source_dir"/* "$dest_dir"/
	sudo rm -rf "$duikLoc"
}

download_and_unzip "${url}"
move_and_cleanup

exit 0
