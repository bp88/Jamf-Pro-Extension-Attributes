#!/bin/zsh
# Purpose: List of apps on the client that require TCC authorization and whether they have been enabled or disabled.
#
# Potential values include:
# -Cannot Access TCC.db
# -No Apps Configured For PPPC
# -List of PPPC/TCC services, status, bundle identifier/path to binary, code requirement 
#   Note: if no code requirement is found: "No Longer Installed" is displayed instead
#   e.g. ScreenCapture - On: com.apple.screensharing.agent - identifier "com.apple.screensharing.agent" and anchor apple
#        ScreenCapture - On: us.zoom.ZoomPresence - Not Installed
#        Accessibility - Off: /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/Support/AEServer - identifier "com.apple.AEServer" and anchor apple

# Variable to query TCC.db
sql_results="$(/usr/bin/sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" "select * from access;")"

# If database cannot be queried then exit script
if [[ $? -ne 0 ]]; then
    echo "<result>Cannot Access TCC.db</result>"
    exit 0
fi

# Variable containing sorted results from sql query on TCC.db
tcc_results="$(echo "$sql_results" | /usr/bin/awk -F'|' -v OFS='|' '{ if($4==0) $4="Off"; else $4="On"}; {sub(/kTCCService/, ""); print $1 " - " $4 " - " $2};' | /usr/bin/sort)"

# Loop through each of the TCC results
while read tcc; do
    tcc_entry=$(echo "$tcc" | /usr/bin/awk -F' - ' '{print $3}')
    
    # Check if TCC entry is a path
    # Otherwise the entry is a bundle id which we'll need to use to determine path
    if [[ -e "$tcc_entry" ]]; then
        # TCC entry is already a path
        tcc_entry_path="$tcc_entry"
    else
        # Determine path where bundle identifier is located
        tcc_entry_path=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == $tcc_entry" | /usr/bin/head -n 1)
    fi
    
    # Determine code requirement
    # Redirect stderr to /dev/null since codesign always outputs Executable path
    code_req=$(/usr/bin/codesign -dr - "$tcc_entry_path" 2>/dev/null | /usr/bin/awk -F'> ' '{print $2}')
    
    # It's possible there's a TCC entry but the app has been removed
    # which would lead to an empty code requirement
    [[ -z "$code_req" ]] && code_req="Not Installed"
    
    # Append the code requirement to TCC entry results
    if [[ -z "$result" ]]; then
        # If result variable is empty, do not include newline character
        result="$tcc - $code_req"
    else
        # If result variable is populated, include newline character
        result+="\n$tcc - $code_req"
    fi
done <<< $tcc_results

if [[ -z "$result" ]]; then
    echo "<result>TCC Is Empty</result>"
else
    echo "<result>$result</result>"
fi

exit 0

if [[ -z "$tcc_results" ]]; then
    echo "<result>TCC Is Empty</result>"
else
    echo "<result>$tcc_results</result>"
fi