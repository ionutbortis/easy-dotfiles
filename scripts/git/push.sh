#!/bin/bash

# Accepted args: --schedule=value --export

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/args.sh" "$@"
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources "$@"

push_method="manual"
log_file_name="$push_method-push"
commit_message="<dotfiles> $push_method push"

if [[ "$schedule" ]]; then
  push_method="auto"
  commit_message="<dotfiles> $push_method $schedule push"

  log_file_name="$schedule-push"
fi

setup_log_file "$log_file_name"

export_data() {
  echo "Exporting settings and files to <dotfiles>..."

  eval "$PROJECT_ROOT/scripts/export.sh ${schedule+"--skip-prompt"}"
}

push_submodule() {
  cd "$PRIVATE_FOLDER" && git pull --quiet

  echo -e "\nPushing changes in [ private ] submodule..."
  git add . && git commit . -m "$commit_message" && git push
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
