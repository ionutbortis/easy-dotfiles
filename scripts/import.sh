#!/bin/bash

# TODO explain args
# Accepted args: --schedule=value --only-files --only-dconfs

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/common/args.sh" "$@"
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources "$@"

check_schedule_arg
check_import_export_args

setup_log_file "${schedule:-"manual"}-import""${only_files+"-files"}${only_dconfs+"-dconfs"}"

import_dconfs() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Importing dconfs from [ $data_folder ]..."

  while read -r schema_path; read -r file 
  do
    cat "$data_folder/$file" | dconf load -f "$schema_path"

  done < <(jq -cr "$jq_filter" "$config_json")
}

import_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Importing files from [ $data_folder ]..."

  cd "$data_folder"

  while read -r include; 
  do
    readarray -t include_array < <(echo "$include" | jq -cr "select(. != null) | .[]")

    for file in "${include_array[@]}"; do
      local source=./"${file#*/}"
      local target="${file/#~/"$HOME"}"

      path_exists "$source" \
          || { echo "[ WARN ] Invalid file to import: $file [ source folder: $data_folder ]"; continue; }

      unset local cmd_prefix
      write_permission_check "$target" || local cmd_prefix="sudo"

      local target_parent_dir="$(dirname "$target")"
      $cmd_prefix mkdir -p "$target_parent_dir" \
          && $cmd_prefix rsync -a --no-o -I "$source" "$target_parent_dir"

      set_owner_from_parent "$target"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

import_all_files() {
  echo -e "\nStarted importing files from <dotfiles>..."

  import_files "$APPS_FOLDER" ".[].settings | select(. != null and .include != null) | .include"
  import_files "$MISC_FOLDER" ".[].files | select(. != null and .include != null) | .include"
}

import_all_dconfs() {
  echo -e "\nStarted importing dconfs from <dotfiles>..."

  import_dconfs "$APPS_FOLDER" ".[].settings.dconf | select(. != null) | (.schema_path, .file)"
  import_dconfs "$EXTENSIONS_FOLDER" ".[].dconf | select(. != null) | (.schema_path, .file)"
  import_dconfs "$KEYBINDINGS_FOLDER" ".[] | (.schema_path, .file)"
  import_dconfs "$TWEAKS_FOLDER" ".[] | (.schema_path, .file)"
}

[[ "$schedule" ]] || \
    prompt_user "[ WARN ] This will override the settings on your system with the ones from <dotfiles> !"

[[ "$only_files" ]] && import_all_files && exit
[[ "$only_dconfs" ]] && import_all_dconfs && exit

import_all_files
import_all_dconfs
