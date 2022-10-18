#!/bin/bash

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/private/scripts/defaults.sh"

configure_hostname() {
  echo "Enter the desired computer name"
  read -p "[ default: $DEFAULT_HOST_NAME, press Enter to use default ]: " name
  sudo hostnamectl set-hostname "${name:-"$DEFAULT_HOST_NAME"}"
}

configure_hostname
