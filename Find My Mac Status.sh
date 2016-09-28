#!/bin/sh

# Purpose: To determine whether Find My Mac has been set on Mac.
# Values are stored in NRAM and will be: "Enabled" or "Disabled".

fmmToken=$(/usr/sbin/nvram -x -p | /usr/bin/grep "fmm-mobileme-token-FMM")

if [ -z "$fmmToken" ]; then
    /bin/echo "<result>Disabled</result>"
else
    /bin/echo "<result>Enabled</result>"
fi