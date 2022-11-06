#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

setup_log_file "anacron-setup"

check_anacron_package() {
  command -v anacron &> /dev/null && return

  echo "[ ERROR ] Could not find the 'anacron' command!"
  echo
  echo "Please install the 'anacron' package and come back to this setup."
  echo "[ fedora ] sudo dnf install anacron"
  echo "[ ubuntu ] sudo apt-get install anacron"
  exit 1
}

check_root_ssh_config() {
  local config="$(sudo /bin/bash -c 'cat ~/.ssh/known_hosts 2>/dev/null | grep github.com')"

  [[ "$config" ]] && return

  local known_hosts="~/.ssh/known_hosts"
  echo
  echo "[ WARN ] github.com is not added to root's [ $known_hosts ] file!"
  echo "This will crash the <dotfiles> automatic pushes."
  echo
  echo "You can fix this manually by running this command: "
  echo "sudo /bin/bash -c 'mkdir -p ~/.ssh && ssh-keyscan github.com >> $known_hosts'"
  echo
  confirm_action "Or do it automatically righ now?" || exit 1

  echo -e "\nConfiguring root's [ $known_hosts ] file..."
  sudo /bin/bash -c "mkdir -p ~/.ssh && ssh-keyscan github.com >> $known_hosts"

  [[ $? -eq 0 ]] || { echo "Error while configuring, please try to do it manually..."; exit 1; }

  echo
  echo "The file was successfully configured!"
  echo
  echo "You can check the file contents by running this command:"
  echo "sudo /bin/bash -c 'cat $known_hosts'"
  echo
}

get_sync_script() {
  for file in "${SCHEDULE_FOLDERS[@]/%/"/$SYNC_SCRIPT_NAME"}"; do
    [[ -e "$file" ]] && echo "$file" && return 
  done
}

create_sync_script() {
  local schedule="$1"
  local target_folder="$(printf '%s\n' "${SCHEDULE_FOLDERS[@]}" | grep "$schedule")"

  local sync_script="$target_folder/$SYNC_SCRIPT_NAME"

  echo "Creating <dotfiles> sync script [ "$sync_script" ]..."

  sudo cp "$TEMPLATE_SYNC_SCRIPT" "$sync_script"

  for var_name in HOME USER SSH_AUTH_SOCK PROJECT_ROOT PRIVATE_FOLDER LOGS_DIR; do
    replace_template_var "$var_name" "${!var_name}" "$sync_script"
  done
}

handle_existing_schedule() {
  local sync_script="$1"
  local schedule="$(sed -e 's|.*\.||' -e 's|/.*||' <<< "$sync_script")"

  echo "Automatic git pushes are configured with [ $schedule ] frequency."

  echo "Do you want to:"
  select option in reschedule remove; do 
    [[ "$option" ]] && break || echo "Please input a valid number!"
  done
  echo

  [[ "$option" == "reschedule" ]] \
      && { remove_sync_script; echo; create_new_schedule; return; }

  [[ "$option" == "remove" ]] \
      && remove_sync_script \
      && echo -e "\nAutomatic git push configuration was succesfully removed."
}

create_new_schedule() {
  echo "Select the desired push schedule:"

  select schedule in "${SUPPORTED_SCHEDULES[@]}"; do 
    [[ "$schedule" ]] && break || echo "Please input a valid number!"
  done

  check_root_ssh_config

  create_sync_script "$schedule" \
      && echo -e "\nAutomatic [ $schedule ] pushes were succcesfully configured!"
}

configure_anacron() {
  local sync_script="$(get_sync_script)"

  [[ "$sync_script" ]] && handle_existing_schedule "$sync_script" || create_new_schedule
}

check_anacron_package
configure_anacron
