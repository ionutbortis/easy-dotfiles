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

get_script_file() {
  for folder in "${SCHEDULE_FOLDERS[@]}"; do
    for action in "${ANACRON_ACTIONS[@]}"; do

      local file="$folder/$ANACRON_SCRIPT_PREFFIX""$action"

      [[ -e "$file" ]] && echo "$file" && return 
    done
  done
}

create_script() {
  local action="$1" schedule="$2"
  local target_folder="$(printf '%s\n' "${SCHEDULE_FOLDERS[@]}" | grep "$schedule")"

  local script="$target_folder/$ANACRON_SCRIPT_PREFFIX""$action"

  echo "Creating $PRJ_DISPLAY anacron script [ $script ]..."

  sudo cp "$PROJECT_ROOT/scripts/anacron/$action-template" "$script"
  sudo chmod +x "$script"

  local var_names=( schedule PROJECT_ROOT USER HOME DBUS_SESSION_BUS_ADDRESS )

  for var_name in "${var_names[@]}"; do
    replace_template_var "$var_name" "${!var_name}" "$script"
  done
}

handle_existing_schedule() {
  local script="$1"
  local schedule="$(sed -e 's|.*\.||' -e 's|/.*||' <<< "$script")"
  local action="${script##*-}"

  echo "Automatic $PRJ_DISPLAY [ $action""s"" ] are configured with [ $schedule ] frequency."

  echo "Do you want to:"
  select option in reschedule remove; do 
    [[ "$option" ]] && break || echo "Please input a valid number!"
  done
  echo

  [[ "$option" == "reschedule" ]] \
      && { remove_anacron_script; echo; create_new_schedule; return; }

  [[ "$option" == "remove" ]] \
      && remove_anacron_script \
      && echo -e "\nThe script for automatic actions was succesfully removed."
}

display_action_help() {
  echo "There are two automatic actions available:"
  echo "[ export ] Exports settings from your system and pushes them to the private repository."
  echo "[ import ] Pulls new settings from the private repository and imports them to your system."
  echo
}

create_new_schedule() {
  display_action_help

  echo "Select the automatic action to be performed:"
  select action in "${ANACRON_ACTIONS[@]}"; do 
    [[ "$action" ]] && break || echo "Please input a valid number!"
  done
  echo
  echo "Select the schedule for this action:"
  select schedule in "${SUPPORTED_SCHEDULES[@]}"; do 
    [[ "$schedule" ]] && break || echo "Please input a valid number!"
  done

  create_script "$action" "$schedule" \
      && echo -e "\nAutomatic [ $schedule $action""s"" ] were succcesfully configured!"
}

configure_anacron() {
  local script="$(get_script_file)"

  if [[ "$script" ]]; then 
    handle_existing_schedule "$script"
  else
    create_new_schedule
  fi
}

check_anacron_package
configure_anacron
