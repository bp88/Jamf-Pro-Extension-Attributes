#!/bin/zsh

# An extension attribute script that will list the URL of all the printers.
# If no printers are installed, the value will be "None".
#   e.g. ipp://192.168.1.2/ipp/print

# Variable containing all printers
printer_list="$(/usr/bin/lpstat -v | /usr/bin/awk -F ': ' '{print $2}')"

if [[ -z "$printer_list" ]]; then
    printer_list="None"
fi

/bin/echo "<result>$printer_list</result>"