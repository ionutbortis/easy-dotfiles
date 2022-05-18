#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources

setup_log_file "export"

remove_data_files() {
  local folder_names=(
    "$APPS_FOLDER" 
    "$EXTENSIONS_FOLDER" 
    "$KEYBINDINGS_FOLDER" 
    "$MISC_FOLDER" 
    "$TWEAKS_FOLDER"
  )

  for folder in "${folder_names[@]/#/"$PARENT_DATA_FOLDER/"}"; do
    echo "Removing all files from [$folder]..."
    rm -rf "$folder" && mkdir -p "$folder"
  done
}

dump_settings() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting settings to [$data_folder]..."

  while read -r schema_path; read -r file 
  do
    read -r keys; 

    local dump_file="$data_folder/$file"
    local full_dump="$(dconf dump "$schema_path")"
    
    if [[ "$keys" == "null" ]]; then
      echo "$full_dump" > "$dump_file"

    else
      local keys_array=($( echo "$keys" | tr ',' ' ' | tr -d '[]"' ))
      local filtered_dump=$(grep ${keys_array[@]/#/-e } <<< "$full_dump")

      echo "$full_dump" | head -1 > "$dump_file"
      echo "$filtered_dump" >> "$dump_file"
    fi

  done < <( jq -cr "$jq_filter" "$config_json")
}

export_keybindings_settings() {
  dump_settings "$KEYBINDINGS_FOLDER" ".[] | (.schema_path, .file, .keys)"
}

export_tweaks_settings() {
  dump_settings "$TWEAKS_FOLDER" ".[] | (.schema_path, .file, .keys)"
}

export_extensions_settings() {
  dump_settings "$EXTENSIONS_FOLDER" ".[].settings | select(. != null) | (.schema_path, .file, .keys)"
}

dump_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting files to [$data_folder]..."

  cd "$data_folder"

  while read -r file; 
  do
    local source="${file/#~/"$HOME"}"
    local target=./"$(echo $file | sed -e 's/^~\///' -e 's/^\///')"

    if [[ ! -d $source &&  ! -f $source ]]; then
      echo "[WARN] Invalid file to export: $file" && continue
    fi

    if [[ -d $source ]]; then
      mkdir -p "$target" && rsync -a --delete "$source"/ "$target"
    fi
    if [[ -f $source ]]; then
      mkdir -p "$(dirname "$target")" && cp "$source" "$target"
    fi

  done < <( jq -cr "$jq_filter" "$config_json")
}

export_apps_settings() {
  dump_settings "$APPS_FOLDER" ".[].settings.dconf | select(. != null) | (.schema_path, .file, .keys)"
  dump_files "$APPS_FOLDER" ".[].settings.config_files | select(. != null) | .[] | select(. != \"\")"
}

export_misc_files() {
  dump_files "$MISC_FOLDER" ".[].files | select(. != null) | .[] | select(. != \"\")"
}

[ "$1" == "auto" ] || \
    prompt_user "[WARN] This will override the settings in <dotfiles> with the ones from your system."

remove_data_files
export_keybindings_settings
export_tweaks_settings
export_extensions_settings
export_apps_settings
export_misc_files
