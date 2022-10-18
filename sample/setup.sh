#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

copy_sample() {
  local name="$1"
  echo "Copying sample [ $name ] to private repo..."

  rsync -a "$PROJECT_ROOT/sample/$name"/ "$PRIVATE_FOLDER/$name"
}

configure_defaults() {
  local defaults_script="$PRIVATE_FOLDER/scripts/defaults.sh"

  echo -e "\nConfiguring the values from the [ "$defaults_script" ] script. These will be used later on."

  read -p $'\nEnter the default computer name: ' hostname
  replace_line_in_file "$defaults_script" "DEFAULT_HOST_NAME" "DEFAULT_HOST_NAME=\"$hostname\""

  read -p $'\nEnter the default git user name for <dotfiles> repo: ' git_user
  replace_line_in_file "$defaults_script" "DEFAULT_GIT_USERNAME" "DEFAULT_GIT_USERNAME=\"$git_user\""

  read -p $'\nEnter the default git email for <dotfiles> repo: ' git_email
  replace_line_in_file "$defaults_script" "DEFAULT_GIT_EMAIL" "DEFAULT_GIT_EMAIL=\"$git_email\""
}

push_data() {
  echo -e "\nPushing sample data to private repo..."

  eval "$PROJECT_ROOT/scripts/git/push.sh"
}

copy_sample config 
copy_sample data
copy_sample scripts

configure_defaults

push_data
