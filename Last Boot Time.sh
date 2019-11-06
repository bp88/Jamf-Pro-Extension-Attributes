#!/bin/zsh

# Extension attribute that will display the date (YYYY-MM-DD HH:MM:SS) the computer was
# booted up. If no time can be detected, output will be: "Unknown"

lastBootTime=$(/usr/sbin/sysctl kern.boottime | /usr/bin/awk -F'[ |,]' '{print $5}')

if [[ -z "$lastBootTime" ]]; then
    lastBootTimeString="Unknown"
else
    lastBootTimeString=$(/bin/date -r $lastBootTime +"%F %T")
fi

echo "<result>$lastBootTimeString</result>"