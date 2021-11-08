#!/bin/zsh

# Determines if Microsoft Auto Update is installed and its full version
# Values can be either: version number, "Not Present" or "Unknown"

# Determine if app exists
app="/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/Info.plist"

if [[ ! -e "$app" ]]; then
    echo "<result>Not Present</result>"
    exit 0
fi

# Determine app version
version="$(/usr/bin/defaults read "$app" CFBundleVersion 2>/dev/null | /usr/bin/awk -F, '{print $1}')"

if [[ "${version}" == "" ]]; then
    echo "<result>Unknown</result>"
else
    echo "<result>${version}</result>"
fi