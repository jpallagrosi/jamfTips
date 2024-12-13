# jamfTools

This page contains tools I have built overtime to help improve the efficianty of a jamf instance. \
I update and tweak it regularly. \
**NOTE:** Most scripts require information specific to the organization. Some are configured with parameters. \
Please feel free to raise an issue or submit a pull request for comments and ideas.

**Extension Attributes:**
- [networkCheck](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/EA/networkCheck.sh) Will report missing networks from the list of known networks.

**Installers:**
- [adobePremiereProAddon](https://github.com/jpallagrosi/jamfUsefulScripts/tree/WIP/Installers/Adobe%20Premiere%20Pro%20Add-ons) Details in the repository.
- [ciscoPreInstall](https://github.com/jpallagrosi/jamfUsefulScripts/tree/WIP/Installers/Cisco%20AnyConnect) Details in the repository.
- [duikAngela](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Installers/duikangela.sh) After Effects plugin.
- [jamfSync](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Installers/jamfSync.sh)
- [maxonApps_Login](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Installers/maxonApps_Logins.sh) Installs the entire Maxon suite. Make sure to remove apps that are not required. The script includes login licensing.
- [unrealEpic_multiUser](https://github.com/jpallagrosi/jamfTips/tree/WIP/Installers/UnrealEngine5) Details in the repository.
- [vectorworksPostInstall](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Installers/vectorworksPostInstall.sh) Deploy the installer package in the shared folder. Details in the script.

**Uninstallers:**
- [adobeRemover_userinput](https://github.com/jpallagrosi/jamfTools/tree/WIP/Uninstallers/Adobe%20Remover) Details in the repository.
- [removeAdobeByYear](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Uninstallers/removeAdobeByYear.sh)

**Utilites:** 
- [inception](https://github.com/jpallagrosi/jamfUsefulScripts/tree/WIP/Utilities/Inception) A script to help build deployment workflows. Details in the repository. (Shortlisted for JNUC!)
- [abletonMulti](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Utilities/abletonMulti.sh) Speeds up the manual licensing process for versions 11 and below.
- [mailToOutlook](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Utilities/mailToOutlook.sh) Installs the app and deploys a workflow to set Outlook as the default mail app
- [networkMissingFix](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Utilities/networkMissingFix.sh) Re-adds a missing network using the API. Requires specific elements to be set up in Jamf and can be used alongside the EA networkCheck tool. Details in the script.
- [sketchupLicensing](https://github.com/jpallagrosi/jamfUsefulScripts/blob/WIP/Utilities/sketchupLicensing.sh)
