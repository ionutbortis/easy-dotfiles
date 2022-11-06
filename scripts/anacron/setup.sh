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

  create_sync_script "$schedule" \
      && echo -e "\nAutomatic [ $schedule ] pushes were succcesfully configured!"
}

configure_anacron() {
  local sync_script="$(get_sync_script)"

  [[ "$sync_script" ]] && handle_existing_schedule "$sync_script" || create_new_schedule
}

check_anacron_package
configure_anacron
