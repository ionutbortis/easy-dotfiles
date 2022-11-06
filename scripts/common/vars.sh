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
SCHEDULE_FOLDERS=( "/etc/cron.daily" "/etc/cron.weekly" "/etc/cron.monthly" )

SYNC_SCRIPT_NAME="dotfiles-sync"
TEMPLATE_SYNC_SCRIPT="$PROJECT_ROOT/scripts/anacron/$SYNC_SCRIPT_NAME"

# This method of determining the version only works for Gnome 40+
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1)"
