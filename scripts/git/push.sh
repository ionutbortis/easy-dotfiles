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

setup_log_file "${schedule:-"manual"}-push"

push_submodule() {
  cd "$PRIVATE_FOLDER" && git pull --quiet

  [[ "$schedule" ]] \
      && local message="<dotfiles> auto $schedule push" \
      || local message="<dotfiles> manual push"

  echo "Pushing changes in [ private ] submodule..."
  git add . && git commit . -m "$message"
  git push
}

push_main() {
  cd "$PROJECT_ROOT" && git pull --quiet

  local message="<dotfiles> private repo revision update"

  echo -e "\nPushing changes in main folder..."
  git add . && git commit . -m "$message"
  git push
}

check_git_props
push_submodule
push_main
