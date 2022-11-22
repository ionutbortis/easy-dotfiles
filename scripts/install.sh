#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"
  source "$DEFAULTS_SCRIPT"

}; sources

setup_log_file "install"

APPS_CONFIG_JSON="$PARENT_CONFIG_FOLDER/$APPS_FOLDER/config.json"
EXTENSIONS_CONFIG_JSON="$PARENT_CONFIG_FOLDER/$EXTENSIONS_FOLDER/config.json"

select_setup_distro() {
  echo -e "\nPlease select distro for setup: "

  select DISTRO in "${SUPPORTED_DISTROS[@]}" ; do 
    [[ "$DISTRO" ]] && break || echo "Please input a valid number!"
  done
}

setup() {
  create_work_dir

  cd "$PROJECT_ROOT" && ./scripts/common/setup.sh

  select_setup_distro

  local distro_setup_script="$PRIVATE_FOLDER/scripts/$DISTRO/setup.sh"

  [[ ! -x "$distro_setup_script" ]] \
      && echo -e "\n[ WARN ] $DISTRO setup script cannot be executed! Skipping [ $distro_setup_script ]" \
      && return

  echo -e "\nRunning [ $DISTRO ] specific setup file [ $distro_setup_script ]..."
  "$distro_setup_script"
}

list_apps() {
  local jq_filter=".[] | select(.install.$DISTRO | .!=null and .!=\"\") | .name"

  readarray -t apps_array < <(jq -c "$jq_filter" "$APPS_CONFIG_JSON")

  [[ ${#apps_array[@]} -gt 0 ]] && echo "${apps_array[@]}" || echo "No apps configured for [ $DISTRO ]"
}

install_apps() {
  echo -e "\nStarting installation of the following apps: " && list_apps

  cd "$WORK_DIR" || return

  local jq_filter=".[] | select(.install.$DISTRO | .!=null and .!=\"\") | (.name, .install.$DISTRO)"

  while read -r name; read -r install_cmd; do

    echo -e "\nInstalling [ $name ] app with command: [ $install_cmd ]"
    $install_cmd

  done < <(jq -cr "$jq_filter" "$APPS_CONFIG_JSON")
}

install_extensions() {
  echo -e "\nStarting installation of extensions..."

  cd "$WORK_DIR" || return

  local jq_filter=".[] | select(.url != null and .url != \"\") | (.url, .name)"

  while read -r url; read -r name; do

    echo -e "\nDownloading [ $name ] extension..."

    local ego_id="$(basename "$(dirname "$url")")"
    local request_url="https://extensions.gnome.org/extension-info/?pk=$ego_id&shell_version=$GNOME_SHELL_VERSION"
    local http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")"

    if [[ "$http_response" == @("400"|"404") ]]; then
      echo "[ ERROR ] No extension exists matching the ID: $ego_id and GNOME Shell version $GNOME_SHELL_VERSION (Skipping this)."
      continue
    fi

    local ext_info="$(curl -s "$request_url")"
    local ext_uuid="$(echo "$ext_info" | jq -r '.uuid')"
    local ext_download_url="$(echo "$ext_info" | jq -r '.download_url')"
    
    local ego_download_url="https://extensions.gnome.org""$ext_download_url"
    local package="$ext_uuid".zip

    wget -nv -t 5 "$ego_download_url" -O "$package"

    echo "Installing [ $name ] extension..."
    gnome-extensions install --force "$package"

  done < <(jq -cr "$jq_filter" "$EXTENSIONS_CONFIG_JSON")
}

show_finished_message() {
  echo
  echo "$PRJ_DISPLAY apps and extensions installation finished!"
  echo
  echo "You can check the install log inside the [ $LOGS_DIR ] folder."
  echo "There you can search for any 'error' or 'warn' messages."
  echo
  echo "Log out and log in again to manually enable your installed gnome extensions."
}

setup
install_apps
install_extensions

show_finished_message
clean_work_dir
