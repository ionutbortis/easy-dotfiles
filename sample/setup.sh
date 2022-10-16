#!/bin/bash

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/scripts/common/vars.sh"

copy_sample() {
  local name="$1"

  rsync -a "$PROJECT_ROOT/sample/$name"/ "$PROJECT_ROOT/$name"
}

push_sample() {
  local name="$1"

  echo "Pushing $name sample..."

  cd "$PROJECT_ROOT/$name"
  git add . && git commit -m "<dotfiles> Added sample $name" && git push
}

push_main() {
  echo "Pushing changes in main folder..."

  cd "$PROJECT_ROOT"
  git add . && git commit . -m "<dotfiles> config and data repos revision update" && git push
}

copy_sample config && push_sample config
copy_sample data && push_sample data

push_main
