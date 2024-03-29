#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources

remove_project_root() {
  echo "Removing [ $PROJECT_ROOT ] folder..."

  cd "$HOME" && rm -rf "$PROJECT_ROOT"
}

show_finished_message() {
  [[ $1 -eq 0 ]] && {
    echo -e "\nProject $PRJ_DISPLAY was succesfully removed!"
    return
  }
  echo -e "\n[ WARN ] Project $PRJ_DISPLAY wasn't removed properly!"
}

prompt_user "[ WARN ] This will remove the $PRJ_DISPLAY project from your system."

remove_anacron_script
remove_project_root

show_finished_message $?
