#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

setup_log_file "anacron-setup"

check_anacron_package() {
  while true; do
    command -v anacron &> /dev/null && return

    echo "[ERROR] Could not find the 'anacron' package!"
    echo
    echo "Please open a separate terminal, install the 'anacron' package and come back to this setup."
    echo "[ fedora ] sudo dnf install anacron"
    echo "[ ubuntu ] sudo apt-get install anacron"
    echo
    read -p "Press Enter to continue after the 'anacron' package installation: "

    check_anacron_package
  done
}

crontab_already_configured() {
  crontab -l | sed '/#/d' | grep -q "$CRONTAB_LINE"
}

get_existing_schedule() {
  ( crontab_already_configured && [[ -f "$PRIVATE_ANACRONTAB" ]] ) || return

  for schedule in daily weekly monthly; do
    sed "/#/d" "$PRIVATE_ANACRONTAB" | grep -q "$schedule" \
        && echo "$schedule" && return 
  done
}

read_anacron_schedule() {
  while true; do
    read -p $'\nEnter the desired push schedule [ d (daily) / w (weekly) / m (monthly) ]: ' -n 1 schedule

    case "$schedule" in
      d) echo daily; return;;
      w) echo weekly; return;;
      m) echo monthly; return;; 
    esac
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
  crontab_already_configured || ( crontab -l; echo "$CRONTAB_LINE" ) | crontab -
}

configure_anacrontab() {
  local existing_schedule="$(get_existing_schedule)"

  if [[ "$existing_schedule" ]]; then
    echo "Automatic git pushes are configured with [ $existing_schedule ] frequency."

    local message="Do you want another schedule for git automatic pushes of <dotfiles> private data?"
  else
    local message="Do you want to schedule git automatic pushes of <dotfiles> private data?";
  fi

  confirm_action "$message" || return 1

  check_anacron_package

  local schedule="$(read_anacron_schedule | tr -d " \t\n\r" )"; echo

  create_anacron_config "$schedule" && configure_crontab

  echo -e "\nAutomatic [ $schedule ] pushes where succcesfully configured!"
}

configure_anacrontab
