#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

push_method="manual"
log_file_name="$push_method-push"
commit_message="<dotfiles> push"

if [ "$1" == "auto" ] && [ -n "$2" ]; then
  push_method="auto"
  push_schedule="$2"
  commit_message="<dotfiles> $push_schedule push"

  log_file_name="$push_schedule-push"
fi

setup_log_file "$log_file_name"

export_data() {
  echo "Exporting settings and files to <dotfiles>..."

  eval "$PROJECT_ROOT/scripts/export.sh $push_method"
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

[ "$push_method" == "auto" ] && export_data

check_git_props
push_submodule
push_main