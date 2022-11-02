#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources

setup_log_file "import"

load_settings() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Loading settings from [ $data_folder ]..."

  while read -r schema_path
  do
    read -r file 

    cat "$data_folder/$file" | dconf load -f "$schema_path"

  done < <(jq -cr "$jq_filter" "$config_json")
}

load_keybindings_settings() {
  load_settings "$KEYBINDINGS_FOLDER" ".[] | (.schema_path, .file)"
}

load_tweaks_settings() {
  load_settings "$TWEAKS_FOLDER" ".[] | (.schema_path, .file)"
}

load_extensions_settings() {
  load_settings "$EXTENSIONS_FOLDER" ".[].dconf | select(. != null) | (.schema_path, .file)"
}

load_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Importing files from [ $data_folder ]..."

  cd "$data_folder"

  while read -r include; 
  do
    readarray -t include_array < <(echo "$include" | jq -cr "select(. != null) | .[]")

    for file in "${include_array[@]}"; do
      local source=./"$(echo $file | sed -e 's/^~\///' -e 's/^\///')"
      local target="${file/#~/"$HOME"}"
      unset local cmd_prefix

      [[ ! -d "$source" && ! -f "$source" ]] \
          && echo "[ WARN ] Invalid file to import: $file [ source folder: $data_folder ]" && continue

      local target_parent_dir="$(dirname "$target")"

      dir_permission_check "$target_parent_dir" || local cmd_prefix="sudo"

      [[ -d "$source" ]] && $cmd_prefix mkdir -p "$target" && $cmd_prefix rsync -a "$source"/* "$target"
      [[ -f "$source" ]] && $cmd_prefix mkdir -p "$target_parent_dir" && $cmd_prefix cp "$source" "$target"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

load_apps_settings() {
  load_settings "$APPS_FOLDER" ".[].settings.dconf | select(. != null) | (.schema_path, .file)"
  load_files "$APPS_FOLDER" ".[].settings | select(. != null and .include != null) | .include"
}

load_misc_files() {
  load_files "$MISC_FOLDER" ".[].files | select(. != null and .include != null) | .include"
}

prompt_user "[ WARN ] This will override the settings on your system with the ones from <dotfiles> !"

load_keybindings_settings
load_tweaks_settings
load_extensions_settings
load_apps_settings
load_misc_files
