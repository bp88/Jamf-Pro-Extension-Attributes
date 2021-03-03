#!/bin/zsh

# A script to report Code42 Backup Percentage
# The extension attribute will result in either:
# 0.00 if no backup has completed or
# the percentage rounded to the nearest two decimals.

# Code42 Application Path
Code42Path="/Applications/Code42.app"

# Check if Code42 is installed before anything else
if [[ ! -d "$Code42Path" ]]; then
    echo "<result>0.00</result>"
    exit 0
fi

# Sets value of Code42 Application Log
Code42AppLog="/Library/Logs/CrashPlan/app.log"

# Checks app.log for backup percentage complete and reports it
if [ -f "$Code42AppLog" ]; then
    # Full percentage
    # Code42BackupPercentage="$(/usr/bin/awk -F' ' '/complete/{gsub(/%/,"");print $3}' "$Code42AppLog")"
    # Percentage rounded to 2 decimal places
    Code42BackupPercentage="$(/usr/bin/awk -F' ' '/complete/{printf "%.2f", $3}' "$Code42AppLog")"
    
    # If backup percentage is empty, set it to 0.00
    if [ -z "$Code42BackupPercentage" ]; then
        Code42BackupPercentage="0.00"
    fi
else
    Code42BackupPercentage="0.00"
fi

echo "<result>${Code42BackupPercentage}</result>"