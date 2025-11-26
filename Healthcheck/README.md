# Health check & House keeping

This script is designed to extract information from the Jamf Pro Summary without using the API. It will prompt you to choose which section you want to process (e.g. unused_Packages, disabled_policies)

The script will generate separate output files containing both the number of items and the full list of items found. \
'Report Information' will print the information required to build a Health Check.

**Prerequisites:**
Place the Jamf Pro Summary with its default name 'jamf-pro-summary.txt' in the Downloads folder.

Create the 4 files below that contains only the information needed in the Downloads folder. \
(I've not yet worked out how to generate these automatically)

- scripts.txt 
(Between === Scripts === & === Directory bindings ===)
- packages.txt
(Between === Packages === & === Scripts ===)
- policies.txt
(Between === Policies === & === Configuration Profiles ===)
- SmartGroups.txt
(Between === Smart Computer Groups === & === Computer PreStage Enrollments ===)

Then from these, the script will be able to print the bellow:
- disabled_policies.txt
- unused_packages.txt
- unused_scripts.txt
- NoDependency_SmartGroups.txt

If you need more infomation to be extracted or/and would know how to generate the additional files let me know.

<img width="452" height="349" alt="Screenshot 2025-11-21 at 11 38 40" src="https://github.com/user-attachments/assets/bb537504-731f-4f43-9a4c-209602233356" />
