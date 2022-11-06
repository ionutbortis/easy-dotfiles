#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources

setup_log_file "remove"

remove_sync_script() {
  for file in "${SCHEDULE_FOLDERS[@]/%/"/$SYNC_SCRIPT_NAME"}"; do
    [[ -e "$file" ]] || continue

    echo "Removing <dotfiles> sync script [ "$file" ]..."
    sudo rm "$file"
  done
}

remove_project_root() {
  echo "Removing [ $PROJECT_ROOT ] folder..."

  cd ~ && rm -rf "$PROJECT_ROOT"
}

show_finished_message() {
  [[ $1 -eq 0 ]] \
      && echo -e "\nProject <dotfiles> was succesfully removed!" \
      || echo -e "\n[ WARN ] Project <dotfiles> wasn't removed properly!"
}

prompt_user "[ WARN ] This will remove the <dotfiles> project from your system."

remove_sync_script
remove_project_root
show_finished_message $?
