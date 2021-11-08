#!/bin/zsh

# Purpose of this script is to report the Battery Condition
# Possible values include: Normal, Service, Not Applicable, Unknown
#   Normal: Battery condition is fine.
#   Service: Battery may be in need of service.
#   Unknown: A battery is installed but no condition was picked up. May indicate script needs updating due to new output from system_profiler.
#   Not Applicable: Mac does not use battery (e.g. iMac, iMac Pro, Mac Pro. Mac Mini)
#
# Note: A condition of "Service" can be caused by many reasons. This can include:
#   -using an adapter that supplies power over USB-C
#   -using a power charge that does not meet the power requirements of the device

# Determine if battery is installed
battery_installed_status="$(/usr/sbin/ioreg -r -c "AppleSmartBattery" | /usr/bin/awk '/BatteryInstalled/ {print $3}')"

# Determine battery condition
condition=$(/usr/sbin/system_profiler SPPowerDataType | /usr/bin/awk '/Condition/ {print $2}')


if [[ "$battery_installed_status" == "No" ]] || [[ -z "$battery_installed_status" ]]; then
    condition="Not Applicable"
elif [[ -z "$condition" ]]; then
    condition="Unknown"
fi

echo "<result>$condition</result>"