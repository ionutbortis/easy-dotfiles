#!/bin/bash

check_required() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  "$script_folder/../required.sh" || exit 1

}; check_required

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

PRIVATE_FOLDER="$PROJECT_ROOT/private"

PARENT_CONFIG_FOLDER="$PRIVATE_FOLDER/config"
PARENT_DATA_FOLDER="$PRIVATE_FOLDER/data"

APPS_FOLDER="apps"
EXTENSIONS_FOLDER="extensions"
KEYBINDINGS_FOLDER="keybindings"
MISC_FOLDER="misc"
TWEAKS_FOLDER="tweaks"

LOGS_DIR="$PROJECT_ROOT/logs"
WORK_DIR="$PROJECT_ROOT/tmp"

DEFAULTS_SCRIPT="$PRIVATE_FOLDER/scripts/defaults.sh"

SUPPORTED_SCHEDULES=( "daily" "weekly" "monthly" )

PRIVATE_ANACRON_FOLDER="$PRIVATE_FOLDER/scripts/anacron"
ANACRON_SPOOL_FOLDER="$PRIVATE_ANACRON_FOLDER/spool"

TEMPLATE_ANACRONTAB="$PROJECT_ROOT/scripts/anacron/anacrontab"
PRIVATE_ANACRONTAB="$PRIVATE_ANACRON_FOLDER/anacrontab"

CRONTAB_LINE="@hourly /usr/sbin/anacron -s -t $PRIVATE_ANACRONTAB -S $ANACRON_SPOOL_FOLDER"

# This method of determining the version only works for Gnome 40+
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1)"
