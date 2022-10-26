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

    ❗Important: Please make sure that the repo is not empty (check the 'Add a README file' option).

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
  local branches=( $(list_branches) ) && [[ "${#branches[@]}" -gt 1 ]] && return

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
    echo -e "\nCurrent profile for <dotfiles> private data is: [ $profile ]"
  fi
}

display_profiles() {
  echo -e "\nCreating the <dotfiles> profiles list..."
  local profiles_array=( $(list_branches) )

  echo "Profiles list for <dotfiles> private data:"
  printf "[ %s ]\n" "${profiles_array[@]}"

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

anacron_setup() {
  echo
  cd "$PROJECT_ROOT" && eval "./scripts/anacron/setup.sh"
}

push_git_changes() {
  echo -e "\nPushing the git configuration changes..."

  cd "$PROJECT_ROOT" && eval "./scripts/git/push.sh"
}

check_additional_repo \
    || { display_new_repo_help; configure_additional_repo; }

handle_additional_repo_data

display_profiles
create_new_profile || switch_profile

anacron_setup

push_git_changes
