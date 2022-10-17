#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"
  
  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

setup_log_file "git-setup"

submodule_exists() {
  local folder="$1"

  cd "$PROJECT_ROOT/$folder"
  test "$(git rev-parse --show-superproject-working-tree)" || return 1
}

check_additional_repos() {
  echo "Checking if config and data submodules are already configured..."

  cd "$PROJECT_ROOT" && git pull --quiet

  submodule_exists config && submodule_exists data || return 1
}

display_new_repos_help() {
  local help="
    You need to manually create two separate private repositories in you github account:
    dotfiles-config
    dotfiles-data

    ❗Important: Please make sure that the repos are not empty (check the 'Add a README file' option) and 
    the default branch is 'main'.

    Official guide on how to create github repositories: 
    https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository
  "

  echo "$help" | sed "s/^[ ]*//"
}

add_submodule() {
  local name="$1"

  cd "$PROJECT_ROOT"

  unset repo
  while [ -z ${repo} ]; do
    echo; read -p "Enter the ssh URL for <dotfiles-$name> repo: " repo
  done
  rm -rf "$name" && git submodule add --force "$repo" "$name"
}

configure_additional_repos() {
  echo "You need to provide the ssh repo URLs for <dotfiles-config> and <dotfiles-data>"
  echo "They should look like: "
  echo "git@github.com:your_user_name/dotfiles-config.git"
  echo "git@github.com:your_user_name/dotfiles-data.git"

  add_submodule config
  add_submodule data

  eval "$PROJECT_ROOT/sample/setup.sh"

  cd "$PROJECT_ROOT" && git add . && git commit -m "<dotfiles> Added config and data submodules" && git push
}

list_branches() {
  local folder="$1"
  cd "$PROJECT_ROOT/$folder"

  git branch -r | awk '{ print $1 }' | sed -e '1d' -e 's/origin\///'
}

create_branch() {
  local name="$1"; local folder="$2"

  echo "Creating new branch [ $name ] for $folder"

  cd "$PROJECT_ROOT/$folder" && git checkout -b "$name"
  git push -u origin "$name"
}

switch_branch() {
  local folder="$1"; local name="$2";

  echo "Switching branch for <dotfiles> $folder"

  cd "$PROJECT_ROOT/$folder" && git checkout "$name"
}

default_submodule_profile() {
  local folder="$1"
  local branches=( $(list_branches $folder) )

  switch_branch "$folder" "${branches[0]}"
}

submodule_profile_check() {
  local folder="$1"
  cd "$PROJECT_ROOT/$folder"; local profile="$(git branch --show-current)"

  if [ ! "$profile" ]; then
    echo -e "\n[WARN] There's no profile set for <dotfiles> $folder. Will use default..."
    default_submodule_profile "$folder"

  else
    echo "Current profile for <dotfiles> $folder is: [ $profile ]"
  fi
}

display_profiles() {
  echo "Creating the <dotfiles> profiles list..."
  local profiles_array=( $(list_branches config && list_branches data | sort | uniq -d) )

  echo "Profiles list for <dotfiles> config and data: [ ${profiles_array[@]} ]"

  submodule_profile_check config
  submodule_profile_check data
}

create_new_profile() {
  local message="Do you want to create and use a new profile for this <dotfiles> installation?"
  echo; confirm_action "$message" || return 1

  read -p "Enter the new <dotfiles> profile name: " new_profile

  create_branch "$new_profile" config
  create_branch "$new_profile" data
}

switch_profile() {
  local message="Do you want to switch to another profile for this <dotfiles> installation?"
  echo; confirm_action "$message" || return 1

  read -p "Enter the existing <dotfiles> profile name: " profile

  switch_branch config "$profile"
  switch_branch data "$profile"
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

configure_anacrontab() {
  local message="Do you want to schedule git automatic pushes of <dotfiles> config and data?"
  echo; confirm_action "$message" || return 1

  check_anacron_package

  local schedule="$(read_anacron_schedule | tr -d " \t\n\r" )"; echo

  local script_name="dotfiles-push"
  local script_folder="/etc/cron.$schedule"
  local script_file="$script_folder/$script_name"
  local script_content='#!/bin/sh\n\n'"cd $PROJECT_ROOT && ./scripts/git/push.sh auto $schedule"

  local anacron_folders=(/etc/cron.daily /etc/cron.weekly /etc/cron.monthly)
  for folder in "${anacron_folders[@]}"; do
    sudo rm -f "$folder/$script_name"
  done

  echo -e "$script_content" | sudo tee "$script_file" > /dev/null
  sudo chmod +x "$script_file"

  echo -e "\nAnacron $schedule push configured successfully!"
  echo "Script file [ $script_file ]"
}

check_additional_repos \
    || { display_new_repos_help; configure_additional_repos; }

display_profiles
create_new_profile || switch_profile

configure_anacrontab
