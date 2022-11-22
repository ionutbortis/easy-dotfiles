#!/bin/bash

required=( gnome-shell gnome-extensions curl wget jq dconf git )

check_required() {
  local missing=()

  for name in "${required[@]}"; do
    command -v "$name" &> /dev/null || missing+=( "$name" )
  done

  [[ ${#missing[@]} -eq 0 ]] && return

  echo "[ ERROR ] One or more required commands are unavailable!"
  echo
  echo "List of missing commands: ${missing[*]}"
  echo 
  echo "You can install the missing by using the following command:"
  echo "[ fedora ] sudo dnf install ${missing[*]}"
  echo "[ ubuntu ] sudo apt-get install ${missing[*]}"
  exit 1
}

check_required
