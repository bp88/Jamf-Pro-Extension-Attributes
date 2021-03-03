#!/bin/zsh

# Extension attribute to report all Volume Owners on Apple Silicon Macs
# If a user is found to be a volume owner, the results will be displayed as:
#   Admins: user1, user2 (or "None" if none found)
#   Non-Admins: user1, user2 (or "None" if none found)
#
# If no user is found to have be a volume owner, the result will be:
#   "No Volume Owners"
# If an unsupported file system is found, the result will be:
#   Unsupported File System: (File System Type)
# If an unsupported architecture, the result will be:
#   Unsupported Platform: (architecture)

# Variable to determine File System Personality
fsType="$(/usr/sbin/diskutil info / | /usr/bin/awk 'sub(/File System Personality: /,""){print $0}')"

# Exit if not APFS
if [[ "$fsType" != *APFS* ]]; then
    echo "<result>Unsupported File System: $fsType</result>"
    exit 0
fi

# Variable to determine architecture of Mac
platform=$(/usr/bin/arch)

# Exit if not running on Apple Silicon
if [[ "$platform" != "arm64" ]]; then
    echo "<result>Unsupported Platform: $platform</result>"
    exit 0
fi

# Variable to gather list of admins
# adminusers=$(/usr/bin/dscl . -read /Groups/admin | /usr/bin/awk '/GroupMembership:/{for(i=3;i<=NF;++i)print $i}')

# Creating empty arrays to store admin and non-admin volume owners
volumeOwnerAdmins=()
volumeOwnerUsers=()

# Determine number of APFS users
totalAPFSUsers=$(/usr/sbin/diskutil apfs listUsers / | /usr/bin/awk '/\+\-\-/ {print $2}' | /usr/bin/wc -l)

# Get APFS User information in plist format
apfsUsersPlist=$(/usr/sbin/diskutil apfs listUsers / -plist)

# Loop through all APFS Crypto Users
for (( n=0; n<$totalAPFSUsers; n++ )); do
    # Determine APFS Crypto User UUID
    apfsCryptoUserUUID=$(/usr/libexec/PlistBuddy -c "print :Users:"$n":APFSCryptoUserUUID" /dev/stdin <<<"$apfsUsersPlist")
    
    # Determine volume owner status for APFS Crypto User
    userVolumeOwnerStatus=$(/usr/libexec/PlistBuddy -c "print :Users:"$n":VolumeOwner" /dev/stdin <<<"$apfsUsersPlist")
    
    # If volume owner, determine username, otherwise move to next APFS user
    if [[ "$userVolumeOwnerStatus" = true ]]; then
        username="$(/usr/bin/dscl . -search /Users GeneratedUID ${apfsCryptoUserUUID} | /usr/bin/awk 'NR==1{print $1}')"
    else
        continue
    fi
    
    # For user in local directory, determine if volume owner is an admin
    if [[ -z "$username" ]]; then
        continue
    elif /usr/sbin/dseditgroup -o checkmember -m "$username" admin &>/dev/null; then
        volumeOwnerAdmins+=($username)
    else
        volumeOwnerUsers+=($username)
    fi
done

# Populate list of admin volume owners
if [[ -z ${volumeOwnerAdmins[@]} ]]; then
    voList="$(echo "Admins: None")"
else
    voList="$(echo "Admins: ${volumeOwnerAdmins[1]}")"
    
    for user in ${volumeOwnerAdmins[@]:1}; do
        voList+=", $user"
    done
fi

# Populate list of non-admin volume owners
if [[ -z ${volumeOwnerAdmins[@]} ]] && [[ -z ${volumeOwnerUsers[@]} ]]; then
    voList="$(echo "No Volume Owner")"
elif [[ -z ${volumeOwnerUsers[@]} ]]; then
    voList+="\n$(echo "Non-Admins: None")"
else
    voList+="\n$(echo "Non-Admins: ${volumeOwnerUsers[1]}")"
    
    for user in ${volumeOwnerUsers[@]:1}; do
        voList+=", $user"
    done
fi

echo "<result>$voList</result>"