#!/bin/bash

# Accepted args:
# --schedule=value  Used when script is invoked from a scheduled action.
#                   It will change the log prefix and the commit message
#                   on the privare repo.

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/args.sh" "$@"
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources "$@"

check_schedule_arg

setup_log_file "${SCHEDULE_ARG:-"manual"}-push"

push_submodule() {
  cd "$PRIVATE_FOLDER" || return 
  git pull --quiet

  local message="$PRJ_DISPLAY manual push"
  [[ "$SCHEDULE_ARG" ]] \
      && message="$PRJ_DISPLAY auto $SCHEDULE_ARG push"

  echo "Pushing changes in [ private ] submodule..."
  git add . && git commit . -m "$message"
  git push
}

push_main() {
  cd "$PROJECT_ROOT" || return
  git pull --quiet

  local message="$PRJ_DISPLAY private repo revision update"

  echo -e "\nPushing changes in main folder..."
  git add . && git commit . -m "$message"
  git push
}

check_git_props
push_submodule
push_main
