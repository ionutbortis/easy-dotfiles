#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/vars.sh"
  source "$script_folder/utils.sh"

}; sources

source "$PRIVATE_FOLDER/scripts/defaults.sh"

configure_hostname() {
  echo -e "\nEnter the desired computer name"
  read -p "[ default: $DEFAULT_HOST_NAME, press Enter to use default ]: " name
  sudo hostnamectl set-hostname "${name:-"$DEFAULT_HOST_NAME"}"
}

run_private_common_setup_script() {
  local setup_script="$PRIVATE_FOLDER/scripts/common/setup.sh"

  if [[ ! -x "$setup_script" ]]; then
    echo -e "\n[ WARN ] Private common setup script cannot be executed! Skipping [ $setup_script ]"
    return
  fi

  echo -e "\nRunning private common setup file [ $setup_script ]..." && eval "$setup_script"
}

echo "Starting common setup..."
configure_hostname
run_private_common_setup_script
