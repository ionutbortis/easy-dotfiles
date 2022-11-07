#!/bin/bash

# TODO explain args
# Accepted args: --schedule=value

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

check_git_props
pull_data \
    || { echo -e "[ WARN ] Pull action had git errors, will exit script."; exit 1; }
