#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

setup_log_file "git-setup"

check_additional_repo() {
  echo "Checking if <dotfiles> private repo is already configured..."

  cd "$PROJECT_ROOT" && git pull --quiet

  cd "$PRIVATE_FOLDER"
  test "$(git rev-parse --show-superproject-working-tree)" || return 1
}

display_new_repo_help() {
  local help="
    You need to manually create a separate 'private' repository in your github account:
    dotfiles-private

    ❗Important: Please make sure that the repo is not empty (check the 'Add a README file' option) and 
    the default branch is 'main'.

    Official guide on how to create github repositories: 
    https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository
  "

  echo "$help" | sed "s/^[ ]*//"
}

configure_additional_repo() {
  echo "You need to provide the ssh repo URL for <dotfiles-private>."
  echo "It should look like: "
  echo "git@github.com:your_user_name/dotfiles-private.git"

  cd "$PROJECT_ROOT"

  unset repo
  while [[ -z ${repo} ]]; do
    echo; read -p "Enter the ssh URL for <dotfiles-private> repo: " repo
  done
  rm -rf private && git submodule add --force "$repo" private
}

handle_additional_repo_data() {
  cd "$PRIVATE_FOLDER" && is_empty_folder config || return

  cd "$PROJECT_ROOT"

  echo -e "\nIt seems that <dotfiles> private configuration is empty."
  echo -e "You can use the 'sample' data for bootstraping your <dotfiles> configuration or create it manually.\n"

  local message="Do you want to use the 'sample' data for the private repo?"
  confirm_action "$message" || return

  eval "$PROJECT_ROOT/sample/setup.sh"
}

list_branches() {
  cd "$PRIVATE_FOLDER"

  git branch -r | awk '{ print $1 }' | sed -e '1d' -e 's/origin\///'
}

create_branch() {
  local name="$1"
  echo "Creating new branch [ $name ] for private repo..."

  check_git_props

  cd "$PRIVATE_FOLDER" && git checkout -b "$name"
  git push -u origin "$name"
}

switch_branch() {
  local name="$1";
  echo "Switching branch to [ "$name" ] for private repo..."

  cd "$PRIVATE_FOLDER" && git checkout "$name"
}

default_submodule_profile() {
  local branches=( $(list_branches) )

  switch_branch "${branches[0]}"
}

submodule_profile_check() {
  cd "$PRIVATE_FOLDER"; local profile="$(git branch --show-current)"

  if [[ ! "$profile" ]]; then
    echo -e "\n[WARN] There's no profile set for the private repo. Will use default..."
    default_submodule_profile

  else
    echo "Current profile for <dotfiles> private data is: [ $profile ]"
  fi
}

display_profiles() {
  echo -e "\nCreating the <dotfiles> profiles list..."
  local profiles_array=( $(list_branches) )

  echo "Profiles list for <dotfiles> private data: [ ${profiles_array[@]} ]"

  submodule_profile_check
}

create_new_profile() {
  local message="Do you want to create and use a new profile for this <dotfiles> installation?"
  echo; confirm_action "$message" || return 1

  read -p "Enter the new <dotfiles> profile name: " new_profile

  create_branch "$new_profile"
}

switch_profile() {
  local message="Do you want to switch to another profile for this <dotfiles> installation?"
  echo; confirm_action "$message" || return 1

  read -p "Enter the existing <dotfiles> profile name: " profile

  switch_branch "$profile"
}

push_git_changes() {
  echo -e "\nPushing the git configuration changes..."

  cd "$PROJECT_ROOT" && eval "./scripts/git/push.sh"
}

check_anacron_package() {
  while true; do
    command -v anacron &> /dev/null && return

    echo "[WARNING]: Could not find the 'anacron' package!"
    echo
    echo "Please open a separate terminal, install the 'anacron' package and come back to this setup."
    echo "  fedora: sudo dnf install anacron"
    echo "  ubuntu: sudo apt-get install anacron"
    echo
    read -p "Press Enter to continue after the 'anacron' package installation: "

    check_anacron_package
  done
}

get_existing_schedule() {
  for folder in "${ANACRON_FOLDERS[@]}"; do
    $(ls "$folder/$ANACRON_SCRIPT_NAME" &>/dev/null) && echo "${folder##*.}" && return
  done
}

read_anacron_schedule() {
  while true; do
    read -p $'\nEnter the desired push schedule [ d (daily) / w (weekly) / m (monthly) ]: ' -n 1 schedule

    case "$schedule" in
      d) echo daily; return;;
      w) echo weekly; return;;
      m) echo monthly; return;; 
    esac
  done
}

create_anacron_script() {
  local schedule="$1"

  local script_folder="/etc/cron.$schedule"
  local script_file="$script_folder/$ANACRON_SCRIPT_NAME"
  local script_content='#!/bin/sh\n\n'"cd $PROJECT_ROOT && ./scripts/git/push.sh auto $schedule"

  for folder in "${ANACRON_FOLDERS[@]}"; do
    sudo rm -f "$folder/$ANACRON_SCRIPT_NAME"
  done

  echo -e "$script_content" | sudo tee "$script_file" > /dev/null
  sudo chmod +x "$script_file"

  echo -e "\nAnacron $schedule push configured successfully!"
  echo "Script file [ $script_file ]"
}

configure_anacrontab() {
  local existing_schedule="$(get_existing_schedule)"

  if [[ "$existing_schedule" ]]; then
    echo -e "\nAutomatic git pushes are configured with [ $existing_schedule ] frequency."
    local message="Do you want another schedule for git automatic pushes of <dotfiles> private data?"
  else
    local message="Do you want to schedule git automatic pushes of <dotfiles> private data?"; echo
  fi

  confirm_action "$message" || return 1

  check_anacron_package

  local schedule="$(read_anacron_schedule | tr -d " \t\n\r" )"; echo
  create_anacron_script "$schedule"
}

check_additional_repo \
    || { display_new_repo_help; configure_additional_repo; }

handle_additional_repo_data

display_profiles
create_new_profile || switch_profile

push_git_changes

configure_anacrontab
