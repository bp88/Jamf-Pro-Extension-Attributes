#!/bin/zsh

# This checks to see if the authorizationdb right: system.preferences.energysaver has been set to allow
# Reports:
# "Allow" if set
# "Not Set" if not set
# "Unsupported OS" if OS is lower than 10.9


# Determine OS version
os_ver_major=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d . -f 1)
os_ver_minor=$(/usr/bin/sw_vers -productVersion | /usr/bin/cut -d . -f 2)

# Authorization DB right
db_right="system.preferences.energysaver"

if [[ "$os_ver_major" -eq 10 && "$os_ver_minor" -ge 9 ]] || [[ "$os_ver_major" -ge 11 ]]; then
    # Read value from authorizationdb right
    tmp_plist=$(/usr/bin/security authorizationdb read "$db_right" 2>/dev/null)
    value=$(/usr/libexec/PlistBuddy -c "print :rule:0" /dev/stdin <<<"$tmp_plist" 2>/dev/null)
    
    if [[ "$value" == "allow" ]]; then
        /bin/echo "<result>Allow</result>"
    else
        /bin/echo "<result>Not Set</result>"
    fi
else
    /bin/echo "<result>Unsupported OS</result>"
fi