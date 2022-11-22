#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../scripts/common/vars.sh"
  source "$script_folder/../scripts/common/utils.sh"

}; sources

copy_sample() {
  local name="$1"
  echo "Copying sample [ $name ] to private repo..."

  rsync -a "$PROJECT_ROOT/sample/$name" "$PRIVATE_FOLDER"
}

display_git_info_message() {
  echo
  echo "When you commit something on a repository, git needs some additional information about you:"
  echo "- Your name               e.g. John Doe"
  echo "- Your email address      e.g. john.doe@gmail.com"
  echo
  echo "Note: For email address you need to use the one from your git provider account."
  echo
  echo "Please provide your defaults for these so they can be easily used later on."
  echo
}

configure_defaults() {
  echo -e "\nConfiguring the values from the [ "$DEFAULTS_SCRIPT" ] script."
  echo -e "These will be used later on when needed.\n"

  read -rp "Enter the default computer name: " hostname
  replace_line_in_file "$DEFAULTS_SCRIPT" "DEFAULT_HOST_NAME" "DEFAULT_HOST_NAME=\"$hostname\""

  display_git_info_message

  read -rp "Enter your default git name for $PRJ_DISPLAY repos: " git_name
  replace_line_in_file "$DEFAULTS_SCRIPT" "DEFAULT_GIT_NAME" "DEFAULT_GIT_NAME=\"$git_name\""

  read -rp "Enter your default git email for $PRJ_DISPLAY repos: " git_email
  replace_line_in_file "$DEFAULTS_SCRIPT" "DEFAULT_GIT_EMAIL" "DEFAULT_GIT_EMAIL=\"$git_email\""
}

copy_sample config 
copy_sample data
copy_sample scripts
copy_sample README.md

configure_defaults
