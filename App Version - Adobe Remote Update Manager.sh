#!/bin/zsh

# Determines if Adobe's Remote Update Manager (RUM) is installed and its full version
# Values can be either: version number, "Not Present" or "Unknown"

# Determine if app exists
if [[ -e /usr/local/bin/RemoteUpdateManager ]]; then
    app="/usr/local/bin/RemoteUpdateManager"
elif [[ -e /usr/bin/RemoteUpdateManager ]]; then
    app="/usr/bin/RemoteUpdateManager"
else
    echo "<result>Not Present</result>"
    exit 0
fi

# Determine app version
version=$("${app}" -h 2>&1 | /usr/bin/awk '/version is/{print $5}')

if [[ "${version}" == "" ]]; then
    echo "<result>Unknown</result>"
else
    echo "<result>${version}</result>"
fi