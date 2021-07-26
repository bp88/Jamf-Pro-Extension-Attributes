#!/bin/zsh

# An extension attribute script that reports whether Rosetta 2 is installed:
# Three potential results are:
#   Installed
#   Not Installed
#   Not Applicable

# Variable that outputs the architecture of the hardware
arch=$(/usr/bin/arch)

if [[ "$arch" == "arm64" ]]; then
    # When Rosetta 2 is installed, the process "oahd" is running
    if /usr/bin/pgrep -q "oahd"; then
        result="Installed"
    else
        result="Not Installed"
    fi
else
    result="Not Applicable"
fi

echo "<result>$result</result>"