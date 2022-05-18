#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources

setup_log_file "install"

APPS_CONFIG_JSON="$PARENT_CONFIG_FOLDER/$APPS_FOLDER/config.json"
EXTENSIONS_CONFIG_JSON="$PARENT_CONFIG_FOLDER/$EXTENSIONS_FOLDER/config.json"

get_setup_distro() {
  # TODO remove later!!
  # echo fedora; return

  while true; do
    read -p "Please input distro name for setup [fedora/ubuntu]: " distro
    case "$distro" in
      "fedora" ) echo "$distro"; return;;
      "ubuntu" ) echo "$distro"; return;;
      * ) echo -e "[ERROR] Only 'fedora' and 'ubuntu' are supported.\n" >&2;;
    esac
  done
}

setup() {
  rm -rf "$WORK_DIR" && mkdir -p "$WORK_DIR"

  eval "$PROJECT_ROOT/scripts/common/setup.sh"

  DISTRO=$(get_setup_distro)
  eval "$PROJECT_ROOT/scripts/$DISTRO/setup.sh"
}

list_apps() {
  local jq_filter=".[] | select(.install.$DISTRO | .!=null and .!=\"\") | .name"

  readarray -t apps_array < <(jq -c "$jq_filter" "$APPS_CONFIG_JSON")
  echo ${apps_array[@]}
}

install_apps() {
  echo "Starting installation of the following apps: " && list_apps

  cd $WORK_DIR

  local jq_filter=".[] | select(.install.$DISTRO | .!=null and .!=\"\") | (.name, .install.$DISTRO)"

  while read -r name
  do
    read -r install_cmd 

    echo -e "\nInstalling \"$name\" app with command: [ $install_cmd ]"
    eval "$install_cmd"

  done < <( jq -cr "$jq_filter" "$APPS_CONFIG_JSON")
}

install_extensions() {
  echo "Starting installation of extensions..."

  cd $WORK_DIR

  while read -r ego_id
  do
    read -r name 
    
    echo "Downloading '$name' extension..."

    local request_url="https://extensions.gnome.org/extension-info/?pk=$ego_id&shell_version=$GNOME_SHELL_VERSION"
    local http_response="$(curl -s -o /dev/null -I -w "%{http_code}" "$request_url")"

    if [ "$http_response" = 404 ]; then
        echo "[ERROR] No extension exists matching the ID: $ego_id and GNOME Shell version $GNOME_SHELL_VERSION (Skipping this)."
        continue;
    fi

    local ext_info="$(curl -s "$request_url")"
    local ext_uuid="$(echo "$ext_info" | jq -r '.uuid')"
    local ext_download_url="$(echo "$ext_info" | jq -r '.download_url')"
    
    local ego_download_url="https://extensions.gnome.org$ext_download_url"
    local package="$ext_uuid".zip

    wget -nv -t 5 "$ego_download_url" -O "$package"

    echo "Installing '$name' extension..."
    gnome-extensions install --force "$package"

  done < <( jq -cr '.[] | (.ego_id, .name)' "$EXTENSIONS_CONFIG_JSON")
}

cleanup() {
  echo "Removing [$WORK_DIR] folder..."

  cd "$PROJECT_ROOT" && rm -rf "$WORK_DIR"
}

setup
install_apps
install_extensions

# todo enable_extensions
# todo create separate install script for extensions: extensions/install.sh
# todo create separate install script for apps: apps/install.sh
# jidea settings (and plugins?) export
# vscode plugins and settings export => https://code.visualstudio.com/docs/editor/command-line
# script for weekly dotfiles export and git update added in anacrontab
# other stuff?
cleanup
