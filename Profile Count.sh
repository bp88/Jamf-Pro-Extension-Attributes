#!/bin/zsh

# An extension attribute script that determines how many profiles are installed

# Variable to determine number of profiles based on output from the "profiles" command
profile_lines="$(/usr/bin/profiles -C | /usr/bin/wc -l)"
profile_count="$(($profile_lines - 1))"

if [ "$profile_count" -gt 0 ]; then
    echo "<result>$profile_count</result>"
else
    echo "<result>0</result>"
fi