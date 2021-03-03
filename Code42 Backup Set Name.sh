#!/bin/zsh

# A script to report Code42 Backup Set Name
# The extension attribute will result in 3 potential values depending on what's found:
# No Backup Found:
#   No backup found.
# <Computer Name as reported in Code42>:
#   The computer name that Code42 reports in the web console.
# Not Installed:
#   Code42 is not installed.

# Code42 Application Path
Code42Path="/Applications/Code42.app"

# Check if Code42 is installed before anything else
if [[ ! -d "$Code42Path" ]]; then
    echo "<result>Not Installed</result>"
    exit 0
fi

# Sets value of Code42 Application Log
Code42AppLog="/Library/Logs/CrashPlan/app.log"

# Checks app.log for Backup Set Name and reports it
if [ -f "$Code42AppLog" ]; then
    Code42BackupName="$(/usr/bin/awk -F,  '/COMPUTERS/{getline; gsub(/^[ \t]+|[ \t]+$/,"",$2);  print $2}' "$Code42AppLog")"
    
    if [ "$Code42BackupName" = "" ]; then
        Code42BackupName="No Backup Name Found"
    fi
else
    Code42BackupName="No Backup Name Found"
fi

echo "<result>${Code42BackupName}</result>"