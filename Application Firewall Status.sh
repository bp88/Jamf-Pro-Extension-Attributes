#!/bin/zsh

# Extension attribute that determines the various states of the application firewall
# This will look at the following statuses which can have a value of either "On" or "Off":
#   Firewall: Shows if application firewall is enabled or not
#   Block All: Shows whether "Block all incoming connections" is on
#   Built-In Signed App: Shows whether built-in signed applications will automatically receiving incoming connections
#   Downloaded Signed App: Shows whether downloaded signed applications will automatically receiving incoming connections
#   Stealth Mode: Shows whether stealth mode is on or off
#   Logging Mode: Shows whether logging mode is on or off

global_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
blockall_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getblockall)
allowsigned_state=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getallowsigned)
stealth_mode=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode)
logging_mode=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getloggingmode)

global_st="Off"
blockall_st="Off"
builtin_app_st="Off"
downloaded_app_st="Off"
stealth_st="Off"
logging_st="Off"

# Determine whether Application Firewall is on
if [[ "$global_state" =~ "enabled" ]]; then
    global_st="On"
fi

# Determine whether "Block all incoming connections" is on
if [[ "$blockall_state" =~ "enabled" ]]; then
    blockall_st="On"
fi

# Determine whether built-in signed applications will
# automatically received incoming connections
if [[ "$allowsigned_state" =~ "built-in.*ENABLED" ]]; then
    builtin_app_st="On"
fi

# Determine whether downloaded signed applications will
# automatically received incoming connections
if [[ "$allowsigned_state" =~ "downloaded.*ENABLED" ]]; then
    downloaded_app_st="On"
fi
# Determine whether Stealth mode is on
if [[ "$stealth_mode" =~ "enabled" ]]; then
    stealth_st="On"
fi

# Determine whether logging mode is on
if [[ "$logging_mode" =~ "on" ]]; then
    logging_st="On"
fi


echo "<result>App Firewall: $global_st
Block All: $blockall_st
Built-In Signed App: $builtin_app_st
Downloaded Signed App: $downloaded_app_st
Stealth Mode: $stealth_st
Logging: $logging_st</result>"

exit 0