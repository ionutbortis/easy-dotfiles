#!/bin/bash

# TODO explain args
# Accepted args: --schedule=value --only-files --only-dconfs --full-clean

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/args.sh" "$@"
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources "$@"

check_schedule_arg && check_restriction_args

setup_log_file "${schedule:-"manual"}-export""${only_files+"-files"}${only_dconfs+"-dconfs"}"

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
    local sub_path="$(grep -o '/.*/' <<< "$key" | sed -e 's|[ \t]*||g' -e 's|^/|[|' -e 's|/$|]|')"
    
    [[ "$sub_path" ]] \
        && FILTER_MAP["$sub_path"]="$(sed 's|/.*/||' <<< "$key")" \
        || FILTER_MAP["$root_path"]+=" ""$key"
  done
}

filter_settings() {
  local keys="$1"; local settings="$2"
  local dump_file="$3" && truncate -s 0 "$dump_file"

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

  [[ -s "$dump_file" ]] || { rm "$dump_file"; return; }
  sed -i "1d" "$dump_file"
}

export_dconfs() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting dconfs to [ $data_folder ]..."
  cd "$data_folder"

  while read -r schema_path; read -r file; read -r keys
  do
    local full_dump="$(dconf dump "$schema_path")"
    
    [[ "$keys" == "null" ]] && echo "$full_dump" > "$file" \
        || filter_settings "$keys" "$full_dump" "$file"

  done < <(jq -cr "$jq_filter" "$config_json")
}

export_files() {
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
      local target=./"${file#*/}"

      path_exists "$source" \
          || { echo "[ WARN ] Missing file to export [ $file ]"; continue; }

      unset local cmd_prefix
      read_permission_check "$source" || local cmd_prefix="sudo"

      local target_parent_dir="$(dirname "$target")"

      mkdir -p "$target_parent_dir"
      $cmd_prefix rsync -a --no-o --delete "$source" "$target_parent_dir"

      $cmd_prefix chown -R "$USER:$USER" "$target"
    done

    for file in "${exclude_array[@]}"; do 
      local target=./"${file#*/}" && rm -rf "$target"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

export_all_files() {
  echo -e "\nStarted exporting files to $PRJ_DISPLAY..."

  export_files "$APPS_FOLDER" ".[].settings | select(. != null and .include != null) | (.include, .exclude)"
  export_files "$MISC_FOLDER" ".[].files | select(. != null and .include != null) | (.include, .exclude)"
}

export_all_dconfs() {
  echo -e "\nStarted exporting dconfs to $PRJ_DISPLAY..."

  export_dconfs "$APPS_FOLDER" ".[].settings.dconf | select(. != null) | (.schema_path, .file, .keys)"
  export_dconfs "$EXTENSIONS_FOLDER" ".[].dconf | select(. != null) | (.schema_path, .file, .keys)"
  export_dconfs "$KEYBINDINGS_FOLDER" ".[] | (.schema_path, .file, .keys)"
  export_dconfs "$TWEAKS_FOLDER" ".[] | (.schema_path, .file, .keys)"
}

[[ "$schedule" ]] || \
    prompt_user "[ WARN ] This will override the settings in $PRJ_DISPLAY with the ones from your system."

[[ "$full_clean" ]] && remove_data_files

[[ "$only_files" ]] && export_all_files && exit
[[ "$only_dconfs" ]] && export_all_dconfs && exit

export_all_files
export_all_dconfs
