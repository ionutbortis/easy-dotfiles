#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/vars.sh"
  source "$script_folder/utils.sh"
  source "$DEFAULTS_SCRIPT"

}; sources

configure_hostname() {
  echo -e "\nEnter the desired computer name"
  read -rp "[ default: $DEFAULT_HOST_NAME, press Enter to use default ]: " name

  sudo hostnamectl set-hostname "${name:-"$DEFAULT_HOST_NAME"}"
}

run_private_common_setup_script() {
  local setup_script="$PRIVATE_FOLDER/scripts/common/setup.sh"

  [[ ! -x "$setup_script" ]] \
      && echo -e "\n[ WARN ] Private common setup script cannot be executed!" \
      && echo "Skipping [ $setup_script ]" \
      && return

  echo -e "\nRunning private common setup file [ $setup_script ]..." && "$setup_script"
}

echo "Starting common setup..."

configure_hostname
run_private_common_setup_script
