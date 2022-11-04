#!/bin/bash

# Accepted args: --schedule=value --import

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/args.sh" "$@"
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources "$@"

check_schedule_arg

setup_log_file "${schedule:-"manual"}-pull"

pull_data() {
  echo "Pulling changes from remote repositories..."

  cd "$PROJECT_ROOT" && git pull --recurse-submodules
}

import_data() {
  echo -e "\nImporting settings and files from <dotfiles>..."

  cd "$PROJECT_ROOT" && ./scripts/import.sh "${schedule+"--skip-prompt"}"
}

check_git_props
pull_data \
    || { echo -e "[ WARN ] Pull action had git errors, will exit script."; exit 1; }

[[ "$import" ]] && import_data
