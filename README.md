# jamfUsefulScripts

This page contains tools I have built overtime to help improve the efficianty of a jamf instance. \
I am updating and tweaking it regularly. \
**NOTE** Most scripts requires information from the organisation. Some of them are set with parameters. \
Please feel free to raise an Issue or a Pull request for comments and ideas.

**Extension Attributes:**
- networkCheck: Will report missing networks from the list of known networks.

**Installers:**
- adobePremiereProAddon: Details in the repository. \
- ciscoPreInstall: Details in the repository. \
- duikAngela: After Effects plugin
- jamfSync
- maxonApps_Login: This will install the whole suite, make sure to remove the apps that are not required. The script also includes login licensing.
- unrealEpic_multiUser: Details in the repository. \ 
- vectorworksPostInstall: Deploy the installer package in the shared folder. Details in the script.

**Uninstallers:**
- removeAdobeByYear

**Utilites:** 
- inception Script: Script to help building deployment workflows. Details in the repository. Has been shorlisted for JNUC! \
- abletonMulti: Helps speed up the manual licensing proces. v11 and below. \
- mailToOutlook: Installs the app and deploy a worflow to set the Outlook as default per user.
- networkMissingFix: re add a missing network using the API. Requires elements to be setup in jamf and can be used along with EA _networkCheck_. Details in the script.
- sketchupLicensing.
