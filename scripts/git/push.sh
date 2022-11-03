#!/bin/bash

# Accepted args: --schedule=value --export

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/args.sh" "$@"
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources "$@"

check_schedule_arg

setup_log_file "${schedule:-"manual"}-push"

export_data() {
  echo "Exporting settings and files to <dotfiles>..."

  eval "$PROJECT_ROOT/scripts/export.sh ${schedule+"--skip-prompt"}"
}

push_submodule() {
  cd "$PRIVATE_FOLDER" && git pull --quiet

  [[ "$schedule" ]] \
      && local message="<dotfiles> auto $schedule push" \
      || local message="<dotfiles> manual push"

  echo "Pushing changes in [ private ] submodule..."
  git add . && git commit . -m "$message" && git push
}

push_main() {
  cd "$PROJECT_ROOT" && git pull --quiet

  echo -e "\nPushing changes in main folder..."
  git add . && git commit . -m "<dotfiles> private repo revision update" && git push
}

[[ "$export" ]] && export_data

check_git_props
push_submodule
push_main
