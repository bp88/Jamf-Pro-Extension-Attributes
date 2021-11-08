#!/bin/zsh

# An extension attribute script that reports the "profiles" status
# Three potential results are:
#   profiles are installed on this system
#   profiles are not installed on this system
#   unknown

profile_status="$(/usr/bin/profiles -H)"

if [[ -z "$profile_status" ]]; then
    profile_status="unknown"
fi

echo "<result>$profile_status</result>"