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

crontab_already_configured() {
  crontab -l 2> /dev/null | sed '/#/d' | grep -q "$CRONTAB_LINE"
}

get_existing_schedule() {
  ( crontab_already_configured && [[ -f "$PRIVATE_ANACRONTAB" ]] ) || return

  for schedule in daily weekly monthly; do
    sed "/#/d" "$PRIVATE_ANACRONTAB" | grep -q "$schedule" \
        && echo "$schedule" && return 
  done
}

create_private_gitignore() {
  local file="$PRIVATE_FOLDER/.gitignore"

  echo "${ANACRON_SPOOL_FOLDER#${PRIVATE_FOLDER}/}" >> "$file"

  remove_duplicate_lines "$file"
}

create_anacron_config() {
  local schedule="$1"

  mkdir -p "$ANACRON_SPOOL_FOLDER" && create_private_gitignore  

  cp "$TEMPLATE_ANACRONTAB" "$PRIVATE_ANACRONTAB"

  sed -i "s|PATH_REPLACE|$PROJECT_ROOT|g" "$PRIVATE_ANACRONTAB"
  sed -i "/$schedule/s/#[[:space:]]*//" "$PRIVATE_ANACRONTAB"
}

configure_crontab() {
  crontab_already_configured || ( crontab -l 2> /dev/null; echo "$CRONTAB_LINE" ) | crontab -
}

remove_config() {
  echo "Removing private anacron folder [ $PRIVATE_ANACRON_FOLDER ]..."
  rm -rf "$PRIVATE_ANACRON_FOLDER"

  remove_crontab_config

  echo -e "\nAutomatic git push configuration was succesfully removed."
}

handle_existing_config() {
  local schedule="$1"

  echo "Automatic git pushes are configured with [ $schedule ] frequency."

  echo "Do you want to:"
  select option in reschedule remove; do 
    [[ "$option" ]] && break || echo "Please input a valid number!"
  done
  echo

  [[ "$option" == "reschedule" ]] && handle_new_config && return

  [[ "$option" == "remove" ]] && remove_config && return
}

handle_new_config() {
  echo "Select the desired push schedule:"

  select schedule in daily weekly monthly; do 
    [[ "$schedule" ]] && break || echo "Please input a valid number!"
  done

  create_anacron_config "$schedule" && configure_crontab

  echo -e "\nAutomatic [ $schedule ] pushes were succcesfully configured!"
}

configure_anacrontab() {
  local schedule="$(get_existing_schedule)"

  [[ "$schedule" ]] && handle_existing_config "$schedule" || handle_new_config
}

check_anacron_package
configure_anacrontab
