#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../common/vars.sh"
  source "$script_folder/../common/utils.sh"

}; sources

setup_log_file "git-setup"

check_additional_repo() {
  echo "Checking if $PRJ_DISPLAY private repo is already configured..."

  cd "$PROJECT_ROOT" && git pull --quiet

  cd "$PRIVATE_FOLDER" && {
    test "$(git rev-parse --show-superproject-working-tree)" || return 1
  }
}

display_new_repo_help() {
  local help="
    You need to manually create a separate 'private' repository in your git provider account:
    $PROJECT_NAME-private

    ❗Important: Make sure that the new repo is private and NOT EMPTY❗

    On github you can check the 'Add a README file' option. Other git providers might offer similar features 
    or you need to manually add a simple README.md file to the private repo root.

    Official guide on how to create repositories on github: 
    https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository
  "

  echo "$help" | sed "s/^[ ]*//"
}

configure_additional_repo() {
  cd "$PROJECT_ROOT" || return

  local main_repo_url="$(git ls-remote --get-url)"
  local expected_private_url="${main_repo_url%%/*}/$PROJECT_NAME-private.git"

  echo "You should create it now if it doesn't exist and the URL should look like: "
  echo "$expected_private_url"
  echo
  echo "Enter the URL for the private repo"
  read -rp "[ or press Enter to use '$expected_private_url' ]: " provided_url

  local repo="${provided_url:-$expected_private_url}"
  
  rm -rf private && git submodule add --force "$repo" private
}

handle_additional_repo_data() {
  cd "$PRIVATE_FOLDER" && is_empty_folder config || return

  echo -e "\nIt seems that $PRJ_DISPLAY private configuration is empty."
  echo -e "It's recommended to use the 'sample' data for initializing your configuration.\n"

  local message="Do you want to use the 'sample' data for initializing your private repo?"
  confirm_action "$message" || return

  cd "$PROJECT_ROOT" && ./sample/setup.sh
}

list_branches() {
  cd "$PRIVATE_FOLDER" || return

  git branch -r | awk '{ print $1 }' | sed -e '1d' -e 's/origin\///'
}

create_branch() {
  local name="$1"; cd "$PRIVATE_FOLDER" || return

  echo -e "\nCreating new branch [ $name ] for private repo..."
  check_git_props

  git switch --force-create "$name"
  git push --set-upstream origin "$name"
}

switch_branch() {
  local name="$1"; cd "$PRIVATE_FOLDER" || return

  echo -e "\nSwitching branch to [ $name ] for private repo..."
  check_git_props

  git switch "$name"
}

default_submodule_profile() {
  local default_branch="$(LC_ALL=C git remote show origin | sed -n '/HEAD branch/s/.*: //p')"

  switch_branch "$default_branch"
}

submodule_profile_check() {
  cd "$PRIVATE_FOLDER" || return

  local profile="$(git branch --show-current)"

  [[ "$profile" ]] && {
    echo -e "\nCurrent profile for $PRJ_DISPLAY private data is [ $profile ]"
    return
  }
  echo -e "\n[ WARN ] There's no profile set for the private repo. Will use default..."
  default_submodule_profile
}

display_profiles() {
  echo -e "\nCreating the $PRJ_DISPLAY profiles list..."
  PROFILES_ARRAY=( $(list_branches) )

  echo "Profiles list for private data:"
  printf "[ %s ]\n" "${PROFILES_ARRAY[@]}"

  submodule_profile_check
}

existing_profile_error() {
  local name="$1"
  echo -e "\n[ ERROR ] A profile with name [ $name ] already exists!\n"
}

profile_name_error() {
  local name="$1"
  echo -e "\n[ ERROR ] The provided name [ $name ] is invalid!"
  echo -e "\nPlease see the official git docs on how to name references (branches):"
  echo -e "https://git-scm.com/docs/git-check-ref-format\n"
}

create_new_profile() {
  local message="Do you want to create and use a new profile for this installation?"
  echo; confirm_action "$message" || return 1

  while [[ ! "$valid_name" ]]; do
    read -rp "Enter the new $PRJ_DISPLAY profile name: " name

    [[ " ${PROFILES_ARRAY[*]} " =~ " $name " ]] \
        && { existing_profile_error "$name"; continue; }

    git check-ref-format --branch "$name" &> /dev/null \
        || { profile_name_error "$name"; continue; }

    local valid_name="$name"
  done

  create_branch "$valid_name"
}

switch_profile() {
  local message="Do you want to switch to another profile for this installation?"
  echo; confirm_action "$message" || return 1

  echo "Select the desired $PRJ_DISPLAY profile:"
  select profile in "${PROFILES_ARRAY[@]}"; do 
    [[ "$profile" ]] && break || echo "Please input a valid number!"
  done

  switch_branch "$profile"
}

push_git_changes() {
  local message="Do you want to push your git configuration changes?"
  echo; confirm_action "$message" || return

  echo -e "\nPushing the git configuration changes..."

  cd "$PROJECT_ROOT" && ./scripts/git/push.sh
}

check_additional_repo || {
  display_new_repo_help
  configure_additional_repo
}

handle_additional_repo_data

display_profiles
create_new_profile || switch_profile

push_git_changes
