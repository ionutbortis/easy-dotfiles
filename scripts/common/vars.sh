#!/bin/bash

check_required() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  "$script_folder/../required.sh" || exit 1

}; check_required

get_project_root() {
  local root="$(git rev-parse --show-superproject-working-tree 2>/dev/null)"
  [[ "$root" ]] || root="$(git rev-parse --show-toplevel 2>/dev/null)"

  echo "$root"
}

check_working_dir() {
  [[ "$PROJECT_ROOT" && "$PWD" =~ "$PROJECT_ROOT" ]] && return

  echo "[ ERROR ] $PRJ_DISPLAY scripts invocations should be done from inside the project folder!"
  exit 1
}

PROJECT_NAME="dotfiles"
PRJ_DISPLAY="<"$PROJECT_NAME">"

PROJECT_ROOT="$(get_project_root)" && check_working_dir

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

ANACRON_SCRIPT_PREFFIX="$USER-dotfiles-"
ANACRON_ACTIONS=( "export" "import" )

# This method of determining the version only works for Gnome 40+
GNOME_SHELL_VERSION="$(gnome-shell --version | cut --delimiter=' ' --fields=3 | cut --delimiter='.' --fields=1)"
