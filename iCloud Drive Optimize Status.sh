#!/bin/bash

# Purpose: to grab iCloud Optimize status.
# Values will be: Enabled, Disabled, Never Configured

#Variable to determine major OS version
OSver="$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d . -f 2)"

#Determine OS is 10.12 or greater as Drive Optimization is only available on 10.12+
if [ "$OSver" -ge "12" ]; then
	#Path to PlistBuddy
	plistBud="/usr/libexec/PlistBuddy"

	#Determine logged in user
	loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

	#Check for existence of preference which indicates if optimization has been set
	if [[ -e "/Users/$loggedInUser/Library/Preferences/com.apple.bird.plist" ]]; then
		iCloudOptimizeStatus=$("$plistBud" -c "print optimize-storage" /Users/$loggedInUser/Library/Preferences/com.apple.bird.plist)
		if [ "$iCloudOptimizeStatus" = "true" ]; then
			Status="Enabled"
		fi
		if [ "$iCloudOptimizeStatus" = "false" ]; then
			Status="Disabled"
		fi
	else
		Status="Never Configured"
	fi
fi

/bin/echo "<result>$Status</result>"