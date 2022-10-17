#!/bin/bash

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/private/scripts/defaults.sh"

configure_hostname() {
  echo "Enter the desired computer name"
  read -p "[default: $DEFAULT_HOST_NAME, press Enter to use default]: " name
  sudo hostnamectl set-hostname "${name:-"$DEFAULT_HOST_NAME"}"
}

configure_git() {
  read -p "Enter your git username [default: $DEFAULT_GIT_USERNAME]: " name
  git config --global user.name "${name:-"$DEFAULT_GIT_USERNAME"}"

  read -p "Enter your git email [default: $DEFAULT_GIT_EMAIL]: " email
  git config --global user.email "${email:-"$DEFAULT_GIT_EMAIL"}"
}

configure_hostname
configure_git
