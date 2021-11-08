#!/bin/zsh

# Extension attribute to report on System Integrity Protection status
# Based on the work of Rich Trouton:
# https://derflounder.wordpress.com/2015/12/18/updated-system-integrity-protection-status-reporting-script/
#
# Based on the status reported by "csrutil status" which include:
# System Integrity Protection status: enabled.
# System Integrity Protection status: disabled.
# System Integrity Protection status: enabled (Custom Configuration).
# System Integrity Protection status: unknown (Custom Configuration).
# 
# You can end up with a custom configuration status by using either:
# "csrutil enable --without ARG" or "csrutil enable --with ARG"
# where ARG can be:
#     "kext", "fs", "debug", "dtrace", or "nvram"
# at which point you'll get the following example output:
#     Apple Internal: disabled
#     Kext Signing: disabled
#     Filesystem Protections: disabled
#     Debugging Protections: disabled
#     DTrace Restrictions: disabled
#     NVRAM Protections: disabled
#
# Possible extension attribute values include:
#     Unsupported OS
#     Disabled
#     Set To Enable After Restart
#     Enabled
#     Unknown
#     "Enabled Custom Configuration" with custom config options listed below
#     "Unknown Custom Configuration" with custom config options listed below


osvers_major=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.11.x or higher.
if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 11 ]]; then
    result="<result>Unsupported OS</result>"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]] || [[ ${osvers_major} -ge 11 ]]; then
    # SIP status output through csrutil1
    sip_output="$(/usr/bin/csrutil status)"
    # SIP status in nvram
    sip_nvram_status="$(/usr/sbin/nvram -p | /usr/bin/grep "csr-active-config")"
    
    # Strip the period at the end of the SIP status output
    sip_status=$(echo "$sip_output" | /usr/bin/awk '/status/ {print $5}' | /usr/bin/sed 's/\.$//')
    
    # Check if SIP is disabled AND has an entry in nvram which indicates SIP is clearly not enabled
    if [[ "$sip_status" = "disabled" ]] && [[ "$sip_nvram_status" ]]; then
        result="Disabled"
    # Check if SIP is disabled AND has NO entry in nvram which indicates SIP has been reset to enabled
    # But needs to be restarted before change takes effect
    elif [[ "$sip_status" = "disabled" ]] && [[ -z "$sip_nvram_status" ]]; then
        result="Set To Enable After Restart"
    elif [[ "$sip_status" = "enabled" ]]; then
        sip_status="Enabled"
        result="$sip_status"
    elif [[ "$sip_status" = "unknown" ]]; then
        sip_status="Unknown"
        result="$sip_status"
    fi
    
    # If SIP is enabled or unknown, check if there are any custom SIP configurations.
    if [[ "$sip_status" = "Enabled" || "$sip_status" = "Unknown" ]]; then
        # Custom configurations
        sip_apple_internal=$(/usr/bin/grep -i "Apple Internal" - <<<"$sip_output")
        sip_kext=$(/usr/bin/grep -i "Kext Signing" - <<<"$sip_output")
        sip_filesystem=$(/usr/bin/grep -i "Filesystem Protections" - <<<"$sip_output")
        sip_debug=$(/usr/bin/grep -i "Debugging Restrictions" - <<<"$sip_output")
        sip_dtrace=$(/usr/bin/grep -i "DTrace Restrictions" - <<<"$sip_output")
        sip_nvram=$(/usr/bin/grep -i "NVRAM Protections" - <<<"$sip_output")
        
        [[ "${sip_apple_internal}" ]] && sip_apple_internal=$(/usr/bin/printf "\n$sip_apple_internal")
        [[ "${sip_kext}" ]] && sip_kext=$(/usr/bin/printf "\n$sip_kext")
        [[ "${sip_filesystem}" ]] && sip_filesystem=$(/usr/bin/printf "\n$sip_filesystem")
        [[ "${sip_debug}" ]] && sip_debug=$(/usr/bin/printf "\n$sip_debug")
        [[ "${sip_dtrace}" ]] && sip_dtrace=$(usr/bin/printf "\n$sip_dtrace")
        [[ "${sip_nvram}" ]] && sip_nvram=$(/usr/bin/printf "\n$sip_nvram")
        
        custom_options="$sip_apple_internal$sip_kext$sip_filesystem$sip_debug$sip_dtrace$sip_nvram"
        [[ $custom_options ]] && result+=" Custom Configuration$custom_options"
    fi
fi

/bin/echo "<result>$result</result>"