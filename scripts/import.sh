#!/bin/bash

# TODO explain args
# Accepted args: --schedule=value --only-files --only-dconfs

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/common/args.sh" "$@"
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources "$@"

check_schedule_arg && check_restriction_args

setup_log_file "${schedule:-"manual"}-import""${only_files+"-files"}${only_dconfs+"-dconfs"}"

missing_file_message() {
  local path="$1"
  local relative_path="$(sed -e 's|^/||' -e 's|^|./|' <<< "$path")"

  echo "[ WARN ] Missing file to import [ $relative_path ]" 
}

import_dconfs() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Importing dconfs from [ $data_folder ]..."
  cd "$data_folder" || return

  while read -r schema_path; read -r file 
  do
    [[ -e "$file" ]] || {  missing_file_message "$file"; continue; }

    dconf load -f "$schema_path" < "$file"

  done < <(jq -cr "$jq_filter" "$config_json")
}

restore_permissions() {
  local source="$1" target="$2"
  local file="$source/$PERMISSIONS_FILE"

  sudo bash -c "cd \"$target\" && setfacl --restore=\"$file\"" 
}

import_file_path() {
  local path="$1" data_folder="$2" cmd_prefix="$3"

  local folder="$(dirname "$path")"
  local search="$(basename "$path")"

  local includes_file="$(create_temp_file '_includes')"

  local source="$data_folder/$folder"
  [[ -e "$source" ]] || { missing_file_message "$path"; return; }

  cd "$source" && find . -maxdepth 1 -name "$search" > "$includes_file"
  [[ -s "$includes_file" ]] || { missing_file_message "$path"; return; }

  local target="${folder/#~/"$HOME"}" && $cmd_prefix mkdir -p "$target"

  $cmd_prefix bash -c "cd \"$source\" \
      && tar -c --no-unquote -T \"$includes_file\" | ( cd \"$target\" && tar xf - )"

  [[ "$cmd_prefix" ]] && restore_permissions "$source" "$target"
}

import_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Importing files from [ $data_folder ]..."
  cd "$data_folder" || return

  while read -r include; 
  do
    readarray -t include_array < <(echo "$include" | jq -cr "select(. != null) | .[]")

    for path in "${include_array[@]}"; do
      unset local cmd_prefix
      [[ "$path" =~ ^~ || "$path" =~ ^"$HOME" ]] || local cmd_prefix="sudo"

      import_file_path "$path" "$data_folder" "$cmd_prefix"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

import_all_files() {
  echo -e "\nStarted importing files from $PRJ_DISPLAY..."

  local jq_filter=".[].files | select(. != null and .include != null) | .include"

  import_files "$APPS_FOLDER" "$jq_filter"
  import_files "$MISC_FOLDER" "$jq_filter"
}

import_all_dconfs() {
  echo -e "\nStarted importing dconfs from $PRJ_DISPLAY..."

  local jq_filter=".[].dconf | select(. != null) | (.schema_path, .file)"

  import_dconfs "$APPS_FOLDER" "$jq_filter"
  import_dconfs "$EXTENSIONS_FOLDER" "$jq_filter"
  import_dconfs "$KEYBINDINGS_FOLDER" "${jq_filter/.dconf/}"
  import_dconfs "$TWEAKS_FOLDER" "${jq_filter/.dconf/}"
}

[[ "$schedule" ]] || \
    prompt_user "[ WARN ] This will override the settings on your system with the ones from $PRJ_DISPLAY !"

[[ "$only_files" ]] && { import_all_files; exit; }
[[ "$only_dconfs" ]] && { import_all_dconfs; exit; }

import_all_files
import_all_dconfs
clean_work_dir
