#!/bin/bash

# Prerequisites: 
# Place the Jamf Pro Summary with its default name 'jamf-pro-summary.txt' in the Downloads folder.
# Use a text editor to create the 4 files below that contains only the information needed in the Downloads folder. 
# NOTE textEdit app will add unwanted characters that will compromise the reports
# (I've not yet worked out how to generate these automatically)

# scripts.txt (Between === Scripts === & === Printers ===)
# packages.txt (Between === Packages === & === Scripts ===)
# policies.txt (Between === Policies === & === Configuration Profiles ===)
# SmartGroups.txt (Between === Smart Computer Groups === & === Computer PreStage Enrollments ===)

loggedInUser=$(ls -l /dev/console | awk '{print $3}')
DOWNLOADS="/Users/${loggedInUser}/Downloads"

# Input files expected in Downloads
SUMMARY_FILE="${DOWNLOADS}/jamf-pro-summary.txt"
POLICIES_FILE="${DOWNLOADS}/policies.txt"
PACKAGES_FILE="${DOWNLOADS}/packages.txt"
SCRIPTS_FILE="${DOWNLOADS}/Scripts.txt"
SMARTGROUPS_FILE="${DOWNLOADS}/SmartGroups.txt"

# Output files
REPORT_COPY="${DOWNLOADS}/jamf-pro-summary copy.txt"
DISABLED_POLICIES="${DOWNLOADS}/disabled_policies.txt"
UNUSED_PACKAGES="${DOWNLOADS}/unused_packages.txt"
MULTIUSE_PACKAGES="${DOWNLOADS}/packages_used_in_multiple_policies.txt"
UNUSED_SCRIPTS="${DOWNLOADS}/unused_scripts.txt"
UNUSED_SMARTGROUPS="${DOWNLOADS}/NoDependency_SmartGroups.txt"

NOTES_BLOCK=$(cat <<'EOF'
#### NOTES ####
#API Roles 2 output / No client
#Double check packages
#Double check policies

#### STUFF I CAN'T SEE IN THE SUMMARY / TO BE COLLECTED IN JAMF ####
#LDAP Configured
#Using Automatic Device Enrollment
#ADE Token Expiry
#Apple Education Support
#Cloud Services Connection
#Scripts is not accurate
#Policies
#Directory bindings 

#### SEARCHES IN THE SUMMARY FOR MISSING DATA ####
#SMTP server
#Categories
#Push certificate
#VPP accounts
#Printers
#Disk Encryption Configurations
#Patch managment 
#Devices available in DEP
#LAPS Enabled
#PreStage Enrolment Computer
#PreStage Enrolment Mobile Device
EOF
)

# AppleScript single-select menu
CHOICE=$(osascript <<EOT
set optionsList to {"Report Information", "Disabled Policies", "Unused Packages", "Unused Scripts", "Unused Smart Groups"}
set userChoice to choose from list optionsList with prompt "Choose an action to run:" default items {"Report Information"}
if userChoice is false then
	return "CANCELLED"
else
	return item 1 of userChoice
end if
EOT
)

if [[ "$CHOICE" == "CANCELLED" ]]; then
  echo "User cancelled. Exiting."
  exit 0
fi

# Helper: check file existence and advise user
check_file() {
  local f="$1"
  local desc="$2"
  if [[ ! -f "$f" ]]; then
    osascript -e "display dialog \"Required file not found: ${desc}\n\nPlease place the file at: ${f}\" buttons {\"OK\"} with title \"Missing file\""
    echo "Required file not found: $f"
    exit 1
  fi
}

# Option handlers

run_report_information() {
  check_file "$SUMMARY_FILE" "Jamf Pro summary (jamf-pro-summary.txt)"

  cp "$SUMMARY_FILE" "$REPORT_COPY"

  lines_to_keep_starting_with=(
    "	Installed Version"
    "	Tomcat Version"
    "	Managed Computers"
    "	Managed iOS Devices"
    "	Provider Name"
    "	Unmanaged Computers"
    "	Unmanaged iOS Devices"
    "	SSO enabled"
    "	SSO configuration"
    "	Number of Users"
    "User Groups"
    "	Total Computer Licenses Purchased"
    "	Total Device Licenses Purchased"
    "	api_roles"
    "	Flush Logs Older Than"
    "	categories "
    "	macOS Intune Integration Enabled"
    "	inventory_preload_"
    "	enrollment_customization "
    "Buildings"
    "Departments"
    "Network Segments"
    "Sites"
    "Webhooks"
    "	packages"
    "	policy_deployment"
    "	Check-in Frequency"
    "	extension_attributes "
    "	Collection Frequency"
    "	configurator_enrollment"
  )

  temp_file="$(mktemp)"

  for entry in "${lines_to_keep_starting_with[@]}"; do
    escaped=$(printf "%s\n" "$entry" | sed 's/[][\.*^$(){}?+|/]/\\&/g')
    grep -E "^${escaped}" "$REPORT_COPY" >> "$temp_file"
  done

  if sed -i '' '/KB$/d' "$temp_file" 2>/dev/null; then
    :
  else
    sed '/KB$/d' "$temp_file" > "${temp_file}.new" && mv "${temp_file}.new" "$temp_file"
  fi

  mv "$temp_file" "$REPORT_COPY"

  {
    echo ""
    echo "$NOTES_BLOCK"
  } >> "$REPORT_COPY"

  osascript -e "display dialog \"Report information created:\n${REPORT_COPY}\" buttons {\"OK\"} with title \"Report Complete\""
  echo "Report information saved to: $REPORT_COPY"
}

run_disabled_policies() {
  check_file "$POLICIES_FILE" "Policies (policies.txt)"

  tmp_disabled="$(mktemp)"

  awk '
  BEGIN { name="" }
  {
    sub(/\r$/, "", $0)

    if ($0 ~ /^[[:space:]]*Name/) {
      name = $0
      sub(/^[[:space:]]*Name[[:space:]]*\.*/,"",name)
      sub(/^[[:space:]]*/,"",name)
    }

    if ($0 ~ /^[[:space:]]*Enabled[[:space:]]+/) {
      enabled = $0
      sub(/^[[:space:]]*Enabled[[:space:]]+/,"",enabled)
      gsub(/^[[:space:]]+|[[:space:]]+$/,"",enabled)

      if (tolower(enabled) == "false" && name != "") {
        print name
      }
    }
  }
  ' "$POLICIES_FILE" > "$tmp_disabled"

  disabledCount=$(wc -l < "$tmp_disabled" | tr -d ' ')
  totalCount=$(grep -c "^[[:space:]]*ID[[:space:]]\+[0-9]" "$POLICIES_FILE" || true)

  {
    echo "Found $disabledCount disabled policies out of $totalCount total policies."
    echo ""
    grep -v '^[[:space:]]*$' "$tmp_disabled"
  } > "$DISABLED_POLICIES"

  rm -f "$tmp_disabled"

  osascript -e "display dialog \"Disabled policies report created:\n${DISABLED_POLICIES}\" buttons {\"OK\"} with title \"Report Complete\""
  echo "Disabled policies saved to: $DISABLED_POLICIES"
}

run_unused_packages() {
  check_file "$PACKAGES_FILE" "Packages (packages.txt)"
  check_file "$POLICIES_FILE" "Policies (policies.txt)"

  tempUnused=$(mktemp)
  tempMulti=$(mktemp)

  allPackagesinDB=$(grep Name "$PACKAGES_FILE" | sed -E 's/^.*[.][. ]*//' | sed 's/\\$//' | sed 's/[[:space:]]*$//')

  policies=$(grep -v Heal "$POLICIES_FILE" | grep Package | sed -e 's/^.\{46\}//' | sed 's/\\$//' | sed 's/[[:space:]]*$//')

  IFS=$'\n'
  for package in $allPackagesinDB; do

    packageCount=$(echo "$policies" | grep -F -x -c "$package")

    # Unused packages
    if [[ $packageCount -eq 0 ]]; then
      echo "$package" >> "$tempUnused"
    fi

    # Packages used in multiple policies
    if [[ $packageCount -gt 1 ]]; then
      echo "$package ($packageCount policies)" >> "$tempMulti"
    fi

  done
  unset IFS

  unusedCount=$(wc -l < "$tempUnused" | tr -d ' ')
  multiCount=$(wc -l < "$tempMulti" | tr -d ' ')

  {
    echo "Found $unusedCount unused packages."
    echo ""
    sort "$tempUnused"
  } > "$UNUSED_PACKAGES"

  {
    echo "Found $multiCount packages used in multiple policies."
    echo ""
    sort "$tempMulti"
  } > "$MULTIUSE_PACKAGES"

  rm -f "$tempUnused" "$tempMulti"

  osascript -e "display dialog \"Reports created:\n${UNUSED_PACKAGES}\n\n${MULTIUSE_PACKAGES}\" buttons {\"OK\"} with title \"Report Complete\""

  echo "Unused packages saved to: $UNUSED_PACKAGES"
  echo "Multi-use packages saved to: $MULTIUSE_PACKAGES"
}

run_unused_scripts() {
  check_file "$SCRIPTS_FILE" "Scripts (Scripts.txt)"
  check_file "$POLICIES_FILE" "Policies (policies.txt)"

  tempFile=$(mktemp)

  allScriptsInDB=$(grep Name "$SCRIPTS_FILE" | sed -E 's/^.*[.][. ]*//' | sed 's/\\$//' | sed 's/[[:space:]]*$//')
  policies=$(grep -v Heal "$POLICIES_FILE" | grep Script | sed -e 's/^.\{46\}//' | sed 's/\\$//' | sed 's/[[:space:]]*$//')

  IFS=$'\n'
  for script in $allScriptsInDB; do
    scriptIsInPolicy=$(echo "$policies" | grep -F -c "$script")
    if [[ $scriptIsInPolicy -eq 0 ]]; then
      echo "$script" >> "$tempFile"
    fi
  done
  unset IFS

  unusedCount=$(wc -l < "$tempFile" | tr -d ' ')

  {
    echo "Found $unusedCount unused scripts."
    echo ""
    cat "$tempFile"
  } > "$UNUSED_SCRIPTS"

  rm -f "$tempFile"

  osascript -e "display dialog \"Unused scripts report created:\n${UNUSED_SCRIPTS}\" buttons {\"OK\"} with title \"Report Complete\""
  echo "Unused scripts saved to: $UNUSED_SCRIPTS"
}

run_unused_smartgroups() {
  check_file "$SMARTGROUPS_FILE" "Smart Groups (SmartGroups.txt)"

  tempFile=$(mktemp)

  allNames=$(grep "Name .................." "$SMARTGROUPS_FILE" | sed 's/.*Name .................. //')
  allDeps=$(grep "Dependency Count" "$SMARTGROUPS_FILE" | sed 's/.*Dependency Count *//')

  paste <(echo "$allNames") <(echo "$allDeps") | while IFS=$'\t' read -r name dep; do
      if [[ "$dep" == "0" ]]; then
          echo "$name" >> "$tempFile"
      fi
  done

  unusedCount=$(wc -l < "$tempFile" | tr -d ' ')

  {
      echo "Found $unusedCount unused smart groups."
      echo ""
      cat "$tempFile"
  } > "$UNUSED_SMARTGROUPS"

  rm -f "$tempFile"

  osascript -e "display dialog \"Unused smart groups report created:\n${UNUSED_SMARTGROUPS}\" buttons {\"OK\"} with title \"Report Complete\""
  echo "Unused smart groups saved to: $UNUSED_SMARTGROUPS"
}

# Main dispatch
case "$CHOICE" in
  "Report Information")
    run_report_information
    ;;
  "Disabled Policies")
    run_disabled_policies
    ;;
  "Unused Packages")
    run_unused_packages
    ;;
  "Unused Scripts")
    run_unused_scripts
    ;;
  "Unused Smart Groups")
    run_unused_smartgroups
    ;;
  *)
    echo "Unknown choice: $CHOICE"
    exit 1
    ;;
esac

exit 0