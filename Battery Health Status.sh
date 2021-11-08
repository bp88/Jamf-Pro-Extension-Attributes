#!/bin/zsh

# Purpose of this script is to report the Battery Health Status
# Possible values include: Failure, OK, Unknown, Not Applicable
#   Failure: Battery has failed.
#   OK: Battery health is fine.
#   Unknown: An unknown value was returned.
#   Not Applicable: Mac does not use battery (e.g. iMac, iMac Pro, Mac Pro, Mac Mini)

# Determine if battery is installed
battery_installed_status="$(/usr/sbin/ioreg -r -c "AppleSmartBattery" | /usr/bin/awk '/BatteryInstalled/ {print $3}')"

# Check the battery failure status
result="$(/usr/sbin/ioreg -r -c "AppleSmartBattery" | /usr/bin/awk '/PermanentFailureStatus/ {print $3}')"

if [[ "$battery_installed_status" == "No" ]]; then
    result="Not Applicable"
elif [[ $result -eq 1 ]]; then
    result="Failure"
elif [[ $result -eq 0 ]]; then
    result="OK"
elif [[ -z "$result" ]]; then
    result="Unknown"
fi

echo "<result>$result</result>"