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
  echo -e "Pulling changes from remote repositories...\n"

  for folder in "$PROJECT_ROOT" "$PRIVATE_FOLDER"; do
    echo "Processing local repo folder [ $folder ]..."

    cd "$folder" && git pull
  done
}

check_git_props
pull_data || \
    { echo -e "\n[ WARN ] Pull action had git errors, will exit script."; exit 1; }
