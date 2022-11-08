#!/bin/bash

# The 'SUPPORTED_DISTROS' configuration should be left as a bash array and its elements 
# should be strings containing STRICTLY only letters, numbers and the underscore _ character.
#
# No spaces, dashes or other characters are allowed inside distro names except underscore!
#
# If you want to use multiple words, you can use the camel case style or an underscore:
# => camelCase: "popOS" "linuxMint" "openSUSE"
# => underscore: "pop_OS" "linux_mint" "open_SUSE"
# 
# The corresponding distro folder names inside the [ <project_root>/private/scripts ] folder
# must match EXACTLY the SUPPORTED_DISTROS entries. 
#
# When running the [ <project_root>/scripts/install.sh ] script you are prompted to select the
# distro for setup and it will try to find a custom distro setup file to invoke:
# [ <project_root>/private/scripts/SUPPORTED_DISTRO_NAME/setup.sh ]
#
# Also, the install script will gather the list of apps to be installed by using the selected
# distro for setup. See the [ <project_root>/private/config/apps/config.json ] file.
#
SUPPORTED_DISTROS=( "fedora" "ubuntu" )

DEFAULT_HOST_NAME="myPC"

DEFAULT_GIT_NAME="My Name"
DEFAULT_GIT_EMAIL="my.git.account.email@domain.com"
