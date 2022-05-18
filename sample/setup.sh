#!/bin/bash

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
source "$PROJECT_ROOT/scripts/common/vars.sh"

copy_sample() {
  local name="$1"

  rsync -a "$PROJECT_ROOT/sample/$name"/ "$PROJECT_ROOT/$name"
}

push_sample() {
  local name="$1"
  
  cd "$PROJECT_ROOT/$name" && git add . && git commit -m "<dotfiles> Added sample $name" && git push
}

copy_sample config && push_sample config
copy_sample data && push_sample data

# this script will help users setup config and data samples:

#- provide simple configuration sample with some apps, tweaks, extensions, etc,
#  also try to cover all the config json use cases and supported configurations

#- provide data samples for the above configurations. include also custom app install scripts
