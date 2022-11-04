#!/bin/bash

# Accepted args: --skip-prompt

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/args.sh" "$@"
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources "$@"

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
    echo "Removing all files from [ $folder ]..."
    rm -rf "$folder" && mkdir -p "$folder"
  done
}

declare -A FILTER_MAP

create_filter_map() {
  local keys="$1"
  local root_path="[/]"

  readarray -t keys_array < <(echo "$keys" | jq -cr ".[]")

  for key in "${keys_array[@]}"; do
    local sub_path="$(grep -o '#.*#' <<< "$key" | sed -e 's/^#/[/' -e 's/#$/]/')"
    
    [[ "$sub_path" ]] \
        && FILTER_MAP["$sub_path"]="${key##*\#}" \
        || FILTER_MAP["$root_path"]+=" ""$key"
  done
}

filter_settings() {
  local keys="$1"; local settings="$2"; local dump_file="$3"

  create_filter_map "$keys"
  
  local current_sub_path="none"

  while read -r line; do
    [[ ! "$line" ]] && continue

    [[ "$line" =~ ^\[.*\]$ ]] && current_sub_path="$line"

    [[ " ${!FILTER_MAP[@]} " =~ " $line " ]] \
        && echo -e "\n$line" >> "$dump_file" && continue

    local filter_keys=( ${FILTER_MAP["$current_sub_path"]} )

    [[ "${#filter_keys[@]}" -gt 0 ]] && grep -q ${filter_keys[@]/#/-e } <<< "$line" \
        && echo "$line" >> "$dump_file" && continue

    [[ "${#filter_keys[@]}" -eq 0 && " ${!FILTER_MAP[@]} " =~ " $current_sub_path " ]] \
        && echo "$line" >> "$dump_file" && continue

  done <<< "$settings"

  [[ -f "$dump_file" ]] && sed -i "1d" "$dump_file"
}

dump_settings() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting settings to [ $data_folder ]..."

  while read -r schema_path; read -r file 
  do
    read -r keys; 

    local dump_file="$data_folder/$file"
    local full_dump="$(dconf dump "$schema_path")"
    
    [[ "$keys" == "null" ]] && echo "$full_dump" > "$dump_file" \
        || filter_settings "$keys" "$full_dump" "$dump_file"

  done < <(jq -cr "$jq_filter" "$config_json")
}

export_keybindings_settings() {
  dump_settings "$KEYBINDINGS_FOLDER" ".[] | (.schema_path, .file, .keys)"
}

export_tweaks_settings() {
  dump_settings "$TWEAKS_FOLDER" ".[] | (.schema_path, .file, .keys)"
}

export_extensions_settings() {
  dump_settings "$EXTENSIONS_FOLDER" ".[].dconf | select(. != null) | (.schema_path, .file, .keys)"
}

dump_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting files to [ $data_folder ]..."

  cd "$data_folder"

  while read -r include; read -r exclude
  do
    readarray -t include_array < <(echo "$include" | jq -cr "select(. != null) | .[]")
    readarray -t exclude_array < <(echo "$exclude" | jq -cr "select(. != null) | .[]")

    for file in "${include_array[@]}"; do
      local source="${file/#~/"$HOME"}"
      local target=./"$(echo $file | sed -e 's/^~\///' -e 's/^\///')"

      [[ ! -d "$source" &&  ! -f "$source" ]] \
          && echo "[ WARN ] Invalid file to export: $file" && continue

      [[ -d "$source" ]] && mkdir -p "$target" && rsync -a --delete "$source"/ "$target"
      [[ -f "$source" ]] && mkdir -p "$(dirname "$target")" && cp "$source" "$target"
    done

    for file in "${exclude_array[@]}"; do
      local target=./"$(echo $file | sed -e 's/^~\///' -e 's/^\///')"
      rm -rf "$target"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

export_apps_settings() {
  dump_settings "$APPS_FOLDER" ".[].settings.dconf | select(. != null) | (.schema_path, .file, .keys)"
  dump_files "$APPS_FOLDER" ".[].settings | select(. != null and .include != null) | (.include, .exclude)"
}

export_misc_files() {
  dump_files "$MISC_FOLDER" ".[].files | select(. != null and .include != null) | (.include, .exclude)"
}

[[ "$skip_prompt" ]] || \
    prompt_user "[ WARN ] This will override the settings in <dotfiles> with the ones from your system."

remove_data_files
export_keybindings_settings
export_tweaks_settings
export_extensions_settings
export_apps_settings
export_misc_files
