#!/bin/bash

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/scripts/common/vars.sh"

copy_sample() {
  local name="$1"

  rsync -a "$PROJECT_ROOT/sample/$name"/ "$PRIVATE_FOLDER/$name"
}

push_samples() {
  echo "Pushing changes in [ private ] submodule..."

  cd "$PRIVATE_FOLDER"
  git add . && git commit -m "<dotfiles> Added samples" && git push
}

push_main() {
  echo "Pushing changes in main folder..."

  cd "$PROJECT_ROOT"
  git add . && git commit . -m "<dotfiles> private repo revision update" && git push
}

copy_sample config 
copy_sample data
copy_sample scripts

push_samples
push_main
