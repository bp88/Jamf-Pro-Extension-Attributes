#!/bin/zsh

# This is an extension attribute script to report Code42 status
# There are 4 possible values with definitions below:
# On, Logged In: ${Code42User}:
#   Application is running and user is logged in
# On, Not Logged In:
#   Application is running but user is not logged in
# Off:
#   Application is not running
# Not Installed:
#   Code42 Is Not Installed

# Code42 Application Path
Code42Path="/Applications/Code42.app"

# Check if Code42 is installed before anything else
if [[ ! -d "$Code42Path" ]]; then
    echo "<result>Not Installed</result>"
    exit 0
fi

# Sets value of Code42 Application Log
Code42AppLog="/Library/Logs/CrashPlan/app.log"

#If value is 0, no user is logged in to Code42
Code42LoggedIn="$(/usr/bin/awk '/USER/{getline; gsub("\,",""); print $1; exit }' $Code42AppLog)"

# Gets Code42 username
Code42User="$(/usr/bin/awk '/USER/{getline; gsub("\,",""); print $2; exit }' $Code42AppLog)"

# Checks if Code42 Client is Running
Code42Running="$(/usr/bin/pgrep "Code42Service")"


# Reports Code42 Status and Username
if [[ -n "${Code42Running}" ]]; then
    Code42Status="On, "
    if [[ "${Code42LoggedIn}" -eq 0 ]]
    then
        Code42Status+="Not Logged In"
    else
        Code42Status+="Logged In: ${Code42User}"
    fi
else
    Code42Status="Off"
fi

echo "<result>${Code42Status}</result>"