#!/bin/bash

setup_log_file() {
  local name="$1" history_folder="history"

  mkdir -p "$LOGS_DIR/$history_folder"
  
  cd "$LOGS_DIR" && mv "$name"* "$history_folder" 2> /dev/null

  cd "$history_folder" && {
    ls -tr "$name"* 2> /dev/null | head -n -3 | xargs --no-run-if-empty rm 
  }

  local new_log_file="$LOGS_DIR"/"$name"_"$(date +'%Y-%m-%d_%H:%M:%S')".log

  echo -e "*** Script output is saved to [ $new_log_file ] ***\n"
  exec > >( tee "$new_log_file" ) 2>&1
}

create_work_dir() {
  cd "$PROJECT_ROOT" && mkdir -p "$WORK_DIR"
}

clean_work_dir() {
  cd "$PROJECT_ROOT" && rm -rf "$WORK_DIR" && create_work_dir
}

create_temp_file() {
  local suffix="$1"
  create_work_dir && mktemp --tmpdir="$WORK_DIR" --suffix="$suffix"
}

confirm_action() {
  while true; do
    read -rp "$1 [y/n]: " -n 1 answer

    case "$answer" in
      y) echo; return 0;;
      n) echo; return 1;;

      *) echo -e "\nPlease answer with 'y' or 'n'.\n";;
    esac
  done
}

prompt_user() {
  echo "$1"
  confirm_action "Are you sure that you want to do this?" || exit 0
}

is_empty_folder() {
  local folder="$1"

  [[ "$(ls -A "$folder" 2> /dev/null)" ]] && return 1 || return 0
}

write_permission_check() {
  local path="$1"

  test -e "$path" || { write_permission_check "$(dirname "$path")"; return $?; }
  test -w "$path"
}

replace_template_var() {
  local var_name="$1" var_value="$2" file="$3"
  local var_suffix="_@REPLACE"

  write_permission_check "$file" || local cmd_prefix="sudo"

  $cmd_prefix sed -i "s|$var_name$var_suffix|$var_value|g" "$file"
}

replace_line_in_file() {
  local file="$1" line_prefix="$2" replacement_line="$3"

  sed -i "s/^$line_prefix.*$/$replacement_line/g" "$file"
}

replace_config_property() {
  local config_file=$1 property_name=$2 property_value=$3

  local value_separator="=" comment_prefix="#"

  local section_prefix="$comment_prefix""$comment_prefix""$comment_prefix"

  local section_start="$section_prefix Start $PRJ_DISPLAY changes"
  local section_end="$section_prefix End $PRJ_DISPLAY changes"

  local section_pattern="/^$section_start/,/^$section_end"
  local property_pattern="^\s*$property_name$value_separator"

  local property_line="$property_name""$value_separator""$property_value"

  local existing_property_config="$(sed -n "$section_pattern/! p" "$config_file" | grep "$property_pattern")"
  [[ "$existing_property_config" ]] && {
    echo "[ WARN ] Property <$property_name> is already configured! Will be commented out [ file: $config_file ]"
  }

  local comment_line="$comment_prefix Commented out by $PRJ_DISPLAY"
  sed "$section_pattern/! s/$property_pattern/$comment_line\n$comment_prefix &/" -i "$config_file"

  local config_section="$(sed -n "$section_pattern/ p" "$config_file")"
  [[ "$config_section" ]] || {
    echo -e "\n\n$section_start\n$property_line\n$section_end" >> "$config_file"
    return
  }

  local section_property="$(echo "$config_section" | grep "$property_pattern")"
  [[ "$section_property" ]] && {
    sed -e "$section_pattern/ s/$property_pattern.*/$property_line/" -i "$config_file"
    return
  }
  sed -e "s/^$section_end/$property_line\n&/g" -i "$config_file"
}

configure_git_props() {
  echo -e "\n[ WARN ] Git needs additional info for the $PRJ_DISPLAY repos.\n"

  source "$DEFAULTS_SCRIPT"

  read -rp "Enter your git name [ default: $DEFAULT_GIT_NAME, press Enter to use default ]: " name
  read -rp "Enter your git email [ default: $DEFAULT_GIT_EMAIL, press Enter to use default ]: " email

  for folder in "$PROJECT_ROOT" "$PRIVATE_FOLDER"; do
    cd "$folder" && {
      git config user.name "${name:-$DEFAULT_GIT_NAME}"
      git config user.email "${email:-$DEFAULT_GIT_EMAIL}"
    }
  done
}

check_git_props() {
  local missing="false"

  for folder in "$PROJECT_ROOT" "$PRIVATE_FOLDER"; do
    cd "$folder" && {
      local name="$(git config user.name)"
      local email="$(git config user.email)"
    }
    [[ "$name" && "$email" ]] || missing="true"
  done

  [[ "$missing" == "true" ]] && configure_git_props
}

check_schedule_arg() {
  [[ "$schedule" ]] || return

  [[ " ${SUPPORTED_SCHEDULES[*]} " =~ " $schedule " ]] && return

  echo "[ ERROR ] Script argument '--schedule' has invalid value [ $schedule ]"
  echo "Valid values are:" && printf "%s\n" "${SUPPORTED_SCHEDULES[@]}"
  exit 1
}

check_restriction_args() {
  [[ "$only_files" && "$only_dconfs" ]] && {
    echo "[ ERROR ] Using both '--only-files' and '--only-dconfs' args is prohibited!"
    exit 1
  }
}

remove_anacron_script() {
  for folder in "${SCHEDULE_FOLDERS[@]}"; do
    for action in "${ANACRON_ACTIONS[@]}"; do

      local file="$folder/$ANACRON_SCRIPT_PREFFIX""$action"
      [[ -e "$file" ]] || continue

      echo "Removing $PRJ_DISPLAY anacron script [ $file ]..."
      sudo rm "$file"
    done
  done
}
