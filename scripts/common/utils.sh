#!/bin/bash

setup_log_file() {
  local name="$1"
  local history_folder="history"

  mkdir -p "$LOGS_DIR/$history_folder" && cd "$LOGS_DIR"

  mv "$name"* "$history_folder" 2>/dev/null && cd "$history_folder"
  ls -tr "$name"* 2>/dev/null | head -n -3 | xargs --no-run-if-empty rm 

  local new_log_file="$LOGS_DIR"/"$name"_"$(date +'%Y-%m-%d_%H:%M:%S')".log
  exec > >(tee ${new_log_file}) 2>&1
}

confirm_action() {
  while true; do
    read -p "$1 [y/n]: " -n 1 answer
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

dir_permission_check() {
  if [[ -e "$1" ]]; then
    if [[ -d "$1" && -w "$1" && -x "$1" ]]; then return 0;
      else return 1;
    fi
  else
    dir_permission_check "$(dirname "$1")"
    return $?
  fi
}

is_empty_folder() {
  local folder="$1"

  [[ "$(ls -A "$folder" 2>/dev/null)" ]] && return 1 || return 0
}

replace_line_in_file() {
  local file="$1"; local line_prefix="$2"; local replacement_line="$3"

  sed -i "s/^"$line_prefix".*$/"$replacement_line"/g" "$file"
}

remove_duplicate_lines() {
  local file="$1"

  echo "$(awk '!seen[$0]++' "$file")" > "$file"
}

replace_config_property() {
  local config_file=$1; local property_name=$2; local property_value=$3

  local value_separator="="; local comment_prefix="#"

  local section_prefix="$comment_prefix""$comment_prefix""$comment_prefix"

  local section_start="$section_prefix Start <dotfiles> changes"
  local section_end="$section_prefix End <dotfiles> changes"

  local section_pattern="/^$section_start/,/^$section_end"
  local property_pattern="^\s*$property_name$value_separator"

  local property_line="$property_name""$value_separator""$property_value"

  local existing_property_config="$(sed -n "$section_pattern/! p" "$config_file" | grep "$property_pattern")"
  if [[ "$existing_property_config" ]]; then
    echo "[ WARN ] Property <$property_name> is already configured! Will be commented out. (file: $config_file)"
  fi

  local comment_line="$comment_prefix Commented out by \<dotfiles\>"
  sed "$section_pattern/! s/$property_pattern/$comment_line\n$comment_prefix &/" -i "$config_file"

  local auto_config_section="$(sed -n "$section_pattern/ p" "$config_file")"
  if [[ ! "$auto_config_section" ]]; then
    echo -e "\n\n$section_start\n$property_line\n$section_end" >> "$config_file"
    return
  fi 

  local property_auto_config="$(echo "$auto_config_section" | grep "$property_pattern")"
  if [[ "$property_auto_config" ]]; then
    sed -e "$section_pattern/ s/$property_pattern.*/$property_line/" -i "$config_file"
  else
    sed -e "s/^$section_end/$property_line\n&/g" -i "$config_file"
  fi
}

configure_git_props() {
  echo -e "\n[ WARN ] Git needs additional info for the <dotfiles> repos.\n"

  source "$DEFAULTS_SCRIPT"

  read -p "Enter your git username [ default: $DEFAULT_GIT_USERNAME, press Enter to use default ]: " username
  read -p "Enter your git email [ default: $DEFAULT_GIT_EMAIL, press Enter to use default ]: " email

  for folder in "$PROJECT_ROOT" "$PRIVATE_FOLDER"; do
    cd "$folder"
    git config user.name "${username:-"$DEFAULT_GIT_USERNAME"}"
    git config user.email "${email:-"$DEFAULT_GIT_EMAIL"}"
  done
}

check_git_props() {
  local missing="false"

  for folder in "$PROJECT_ROOT" "$PRIVATE_FOLDER"; do
    cd "$folder"
    local username="$(git config user.name)"
    local email="$(git config user.email)"

    [[ "$username" && "$email" ]] || missing="true"
  done

  [[ "$missing" == "true" ]] && configure_git_props
}
