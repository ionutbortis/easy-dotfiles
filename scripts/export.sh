#!/bin/bash

# TODO explain args
# Accepted args: --schedule=value

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/common/args.sh" "$@"
  source "$script_folder/common/vars.sh"
  source "$script_folder/common/utils.sh"

}; sources "$@"

check_schedule_arg

setup_log_file "${schedule:-"manual"}-export"

remove_data_files() {
  local folder_names=(
    "$APPS_FOLDER" "$EXTENSIONS_FOLDER" "$KEYBINDINGS_FOLDER" "$MISC_FOLDER" "$TWEAKS_FOLDER"
  )
  for folder in "${folder_names[@]/#/"$PARENT_DATA_FOLDER/"}"; do
    echo "Removing all files from [ $folder ]..."
    rm -rf "$folder" && mkdir -p "$folder"
  done
}

declare -A FILTER_MAP

create_filter_map() {
  local keys="$1" root_path="[/]"

  readarray -t keys_array < <(echo "$keys" | jq -cr ".[]")

  for key in "${keys_array[@]}"; do
    local sub_path="$(grep -o '/.*/' <<< "$key" | sed -e 's|[ \t]*||g' -e 's|^/|[|' -e 's|/$|]|')"
    
    [[ "$sub_path" ]] \
        && FILTER_MAP["$sub_path"]="$(sed 's|/.*/||' <<< "$key")" \
        || FILTER_MAP["$root_path"]+=" ""$key"
  done
}

filter_settings() {
  local keys="$1" settings="$2"
  local dump_file="$3" && truncate -s 0 "$dump_file"

  create_filter_map "$keys"
  
  local current_sub_path="none"

  while read -r line; do
    [[ ! "$line" ]] && continue

    [[ "$line" =~ ^\[.*\]$ ]] && current_sub_path="$line"

    [[ " ${!FILTER_MAP[*]} " =~ " $line " ]] \
        && echo -e "\n$line" >> "$dump_file" && continue

    local filter_keys=( ${FILTER_MAP["$current_sub_path"]} )

    [[ "${#filter_keys[@]}" -gt 0 ]] && grep -q ${filter_keys[*]/#/-e } <<< "$line" \
        && echo "$line" >> "$dump_file" && continue

    [[ "${#filter_keys[@]}" -eq 0 && " ${!FILTER_MAP[*]} " =~ " $current_sub_path " ]] \
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
  cd "$data_folder" || return

  while read -r schema_path; read -r file; read -r keys
  do
    local full_dump="$(dconf dump "$schema_path")"
    
    [[ "$keys" == "null" ]] && echo "$full_dump" > "$file" \
        || filter_settings "$keys" "$full_dump" "$file"

  done < <(jq -cr "$jq_filter" "$config_json")
}

create_permissions_file() {
  local source="$1" target="$2"
  local all_permissions="$(sudo bash -c "cd \"$source\" && getfacl -R . ")"

  cd "$target" && rm -f "$PERMISSIONS_FILE"

  local exported_files="$(find . )"

  while read -r file; do
    local section_start="^# file: ${file/#.\//}$"
    printf "%s\n" "$all_permissions" | grep "$section_start" --after-context=6 >> "$PERMISSIONS_FILE"

  done <<< "$exported_files"
}

export_file_path() {
  local path="$1" data_folder="$2" exclude_list="$3" cmd_prefix="$4"

  local folder="$(dirname "$path")"
  local search="$(basename "$path")"

  local includes_file="$(create_temp_file '_includes')"
  local excludes_file="$(create_temp_file '_excludes')"

  local source="${folder/#~/"$HOME"}"

  $cmd_prefix bash -c "cd \"$source\" && find . -maxdepth 1 -name \"$search\"" > "$includes_file"
  [[ -s "$includes_file" ]] \
      || { echo "[ WARN ] Missing file to export [ $path ]"; return; }

  echo "$exclude_list" | grep "^$path" | sed "s|^$folder/|./|g" > "$excludes_file"

  local target="$data_folder/$folder" && mkdir -p "$target"

  $cmd_prefix bash -c "cd \"$source\" \
      && tar -c --no-unquote -X \"$excludes_file\" -T \"$includes_file\" | ( cd \"$target\" && tar xf - )"

  [[ "$cmd_prefix" ]] \
      && sudo chown "$USER":"$USER" -R "$target" \
      && create_permissions_file "$source" "$target"
}

export_files() {
  local data_folder="$PARENT_DATA_FOLDER/$1"
  local config_json="$PARENT_CONFIG_FOLDER/$1/config.json"
  local jq_filter="$2"

  echo "Exporting files to [ $data_folder ]..."

  while read -r include; read -r exclude
  do
    readarray -t include_array < <(echo "$include" | jq -cr "select(. != null) | .[]")
    readarray -t exclude_array < <(echo "$exclude" | jq -cr "select(. != null) | .[]")

    local exclude_list="$(printf '%s\n' "${exclude_array[@]}")"

    for path in "${include_array[@]}"; do
      unset local cmd_prefix
      [[ "$path" =~ ^~ || "$path" =~ ^"$HOME" ]] || local cmd_prefix="sudo"

      export_file_path "$path" "$data_folder" "$exclude_list" "$cmd_prefix"
    done

  done < <(jq -cr "$jq_filter" "$config_json")
}

export_all_files() {
  echo -e "\nStarted exporting files to $PRJ_DISPLAY..."

  local jq_filter=".[].files | select(. != null and .include != null) | (.include, .exclude)"

  export_files "$APPS_FOLDER" "$jq_filter"
  export_files "$MISC_FOLDER" "$jq_filter"
}

export_all_dconfs() {
  echo -e "\nStarted exporting dconfs to $PRJ_DISPLAY..."

  local jq_filter=".[].dconf | select(. != null) | (.schema_path, .file, .keys)"
  
  export_dconfs "$APPS_FOLDER" "$jq_filter"
  export_dconfs "$EXTENSIONS_FOLDER" "$jq_filter" 
  export_dconfs "$KEYBINDINGS_FOLDER" "${jq_filter/.dconf/}"
  export_dconfs "$TWEAKS_FOLDER" "${jq_filter/.dconf/}"
}

[[ "$schedule" ]] || \
    prompt_user "[ WARN ] This will override the settings in $PRJ_DISPLAY with the ones from your system."

remove_data_files
export_all_files
export_all_dconfs
clean_work_dir
