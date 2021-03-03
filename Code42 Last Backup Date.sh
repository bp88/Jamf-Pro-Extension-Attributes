#!/bin/zsh

# An extension attribute script to report the last completed backup date by Code42
# Defaults to "1901-01-01 00:00:01" if backup has never completed

# Sets location of all Code42 History Logs
Code42Logs=$(/bin/ls /Library/Logs/CrashPlan/history.log*)

# Runs a loop to check Code42 history logs for the date and time of most recent Completed Backup
# If found, converts the date format, and reports it. 
# If no completed backup is found, it goes to a previous log.
# If no completed backup is found, it defaults to 1901-01-01 00:00:01

Code42Result="1901-01-01 00:00:01"

for LINE in $(echo $Code42Logs); do
    Code42Date=$(/usr/bin/awk '/Completed\ backup/{print $2, $3}' $LINE | /usr/bin/tail -n1)
    
    if [ -z "$Code42Date" ]; then
        Code42Result="1901-01-01 00:00:01"
        continue 
    else
        Code42Result=$(/bin/date -j -f "%m/%d/%y %l:%M%p" "$Code42Date" "+%Y-%m-%d %k:%M:%S")
        break
    fi
done

echo "<result>${Code42Result}</result>"