#!/bin/bash

check_required() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  eval "$script_folder/../required.sh" || exit 1

}; check_required

PROJECT_ROOT="$(git rev-parse --show-toplevel)"

PRIVATE_FOLDER="$PROJECT_ROOT/private"

PARENT_CONFIG_FOLDER="$PRIVATE_FOLDER/config"
PARENT_DATA_FOLDER="$PRIVATE_FOLDER/data"

KEYBINDINGS_FOLDER="keybindings"
EXTENSIONS_FOLDER="extensions"
TWEAKS_FOLDER="tweaks"
APPS_FOLDER="apps"
MISC_FOLDER="misc"

LOGS_DIR="$PROJECT_ROOT/logs"
WORK_DIR="$PROJECT_ROOT/tmp"

DEFAULTS_SCRIPT="$PRIVATE_FOLDER/scripts/defaults.sh"

# GIT_SILENT="--quiet"

# For Gnome versions 40 and above
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1)"

# For Gnome versions under 40
#GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1,2)"
