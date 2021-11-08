#!/bin/zsh

# Determines if Managed Python 3 is installed and its full version
# This relies on the default path used by the installer for the managed python 3 installer
# as found from: https://github.com/macadmins/python
# Values can be either: version number, "Not Present" or "Unknown"

# Path to binary
app="/usr/local/bin/managed_python3"

# Determine if app exists
if [[ -e "$app" ]]; then
    # Determine app version
    version="$("$app" -V | /usr/bin/awk -F' ' '{print $2}')"
    
    if [[ "${version}" == "" ]]; then
        echo "<result>Unknown</result>"
    else
        echo "<result>${version}</result>"
    fi
else
    echo "<result>Not Present</result>"
    exit 0
fi
