#!/bin/zsh

# Purpose: to get SSH status
# Return value will be: "On" or "Off". 

ssh_status=$(/usr/sbin/systemsetup -getremotelogin | /usr/bin/awk '{ print $3 }')

/bin/echo "<result>$ssh_status</result>"