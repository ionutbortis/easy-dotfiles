#!/bin/bash

required=( gnome-shell gnome-extensions curl wget jq dconf git )

check_required() {
  local error="false"

  for name in "${required[@]}"
  do
    command -v "$name" >/dev/null 2>&1 || { echo "[ERROR] Command not found: $name"; error="true"; }
  done

  if [[ "$error" == "true" ]]; then
    echo "[ERROR] One or more required commands are unavailable!"
    echo "List of required commands: ${required[*]}"
    exit 1
  fi
}

check_required
