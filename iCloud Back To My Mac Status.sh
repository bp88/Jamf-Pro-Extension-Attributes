#!/bin/bash

# Purpose: to grab iCloud Back To My Mac status.
# If Back To My Mac has been setup previously then values should be: "false" or "true"
# If the iCloud account has NOT been setup then value will be: "iCloud Account Disabled"

#Path to PlistBuddy
plistBud="/usr/libexec/PlistBuddy"

#Determine logged in user
loggedInUser=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

#Determine whether user is logged into iCloud
if [[ -e "/Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist" ]]; then
	iCloudStatus=$("$plistBud" -c "print :Accounts:0:LoggedIn" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist 2> /dev/null )

	#Determine whether user has enabled Drive enabled. Value should be either "false" or "true"
	if [[ "$iCloudStatus" = "true" ]]; then
		BackToMyMacStatus=$("$plistBud" -c "print :Accounts:0:Services:12:Enabled" /Users/$loggedInUser/Library/Preferences/MobileMeAccounts.plist 2> /dev/null )
		if [ -z "$BackToMyMacStatus" ]; then
			BackToMyMacStatus="iCloud Account Enabled, Back To My Mac Disabled"
		fi
	fi
	if [[ "$iCloudStatus" = "false" ]] || [[ -z "$iCloudStatus" ]]; then
		BackToMyMacStatus="iCloud Account Disabled"
	fi
fi

/bin/echo "<result>$BackToMyMacStatus</result>"