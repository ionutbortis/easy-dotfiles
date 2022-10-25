#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"

}; sources

setup_log_file "remove"

remove_crontab_config() {
  echo "Removing crontab configuration..."

  crontab -l | sed "s|^$CRONTAB_LINE$||g" | crontab -
}

remove_project_root() {
  echo "Removing [ $PROJECT_ROOT ] folder..."

  cd ~ && rm -rf "$PROJECT_ROOT"
}

show_finished_message() {
  echo -e "\nProject <dotfiles> was succesfully removed!"
}

prompt_user "[WARN] This will remove the <dotfiles> project from your system."

remove_crontab_config
remove_project_root
show_finished_message
