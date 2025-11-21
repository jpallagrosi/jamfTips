# jamfTips

This script is built to extract information from the Jamf Pro Summary without the use of API. It will prompt the user with which section to run e.g. unused_Packages, disabled_policies.

**Prerequisites:**
Leave the Jamf Pro Summary with its default name 'jamf-pro-summary.txt' in the Downloads folder.

Create the 4 files below that contains only the information needed in the Downloads folder. \
(I've not worked out how to create these automatically)

- scripts.txt 
(Between === Scripts === & === Directory bindings ===)
- packages.txt
(Between === Packages === & === Scripts ===)
- policies.txt
(Between === Policies === & === Configuration Profiles ===)
- SmartGroups.txt
(Between === Smart Computer Groups === & === Computer PreStage Enrollments ===)

Then from these you will be able to print the bellow:
- disabled_policies.txt
- unused_packages.txt
- unused_scripts.txt
- NoDependency_SmartGroups.txt

If you need more infomation to be extracted or/and would know how to print the additional files let me know.