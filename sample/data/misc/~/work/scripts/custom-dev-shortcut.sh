#!/bin/bash

# The keyboard shortcut to run this script is SUPER + ALT + ENTER
#
# Here you can add your commands or scripts that you want to leverage during
# development by using the keyboard shortcut mentioned above.

script_folder="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")"
script_name="$(basename "$0")"

log_file="$script_folder/$script_name".log
exec > >(tee "$log_file") 2>&1


# Start Section to add your calls to custom scripts or other commands

~/work/projects/gnome-bedtime-mode/scripts/install.sh --enable-debug-log


# End Section


[[ $? -eq 0 ]] \
    && message="Yaay! Script ran successfully." \
    || message="NOOO! Script run had errors!\n\nCheck log file:\n$log_file"

notify-send "$script_name" "$(echo -e "$message")"
