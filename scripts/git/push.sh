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

  echo "Pushing changes in [ private ] submodule..."
  git add . && git commit . -m "$commit_message" && git push
}

push_main() {
  cd "$PROJECT_ROOT" && git pull --quiet

  echo "Pushing changes in main folder..."
  git add . && git commit . -m "<dotfiles> private repo revision update" && git push
}

configure_git_props() {
  echo -e "\n[WARN] Git needs additional info for the <dotfiles> repo!\n"

  cd "$PROJECT_ROOT"

  source "$PRIVATE_FOLDER/scripts/defaults.sh"

  read -p "Enter your git username [ default: $DEFAULT_GIT_USERNAME, press Enter to use default ]: " username
  git config user.name "${username:-"$DEFAULT_GIT_USERNAME"}"

  read -p "Enter your git email [ default: $DEFAULT_GIT_EMAIL ]: " email
  git config user.email "${email:-"$DEFAULT_GIT_EMAIL"}"
}

check_git_props() {
  cd "$PROJECT_ROOT"

  local username="$(git config user.name)"
  local email="$(git config user.email)"

  [ ! "$username" ] || [ ! "$email" ] && configure_git_props
}

check_git_props

[ "$push_method" == "auto" ] && export_data

push_submodule
push_main
