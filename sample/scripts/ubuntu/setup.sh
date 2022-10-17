#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../../../scripts/common/vars.sh"
  source "$script_folder/../../../scripts/common/utils.sh"

}; sources

echo "[TODO] ubuntu setup needs some love..."
exit 1

# todo check if needed on ubuntu 22.04
add_flatpak_support() {
  sudo apt-get install flatpak -y
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

add_flatpak_support

: '
# install required: jq git
sudo apt-get install jq git etc??

# google chrome repo add
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# vscode repo add
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

sudo apt install apt-transport-https
sudo apt update

# atom repo add
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'

# skype repo
sudo sh -c 'echo "deb [arch=amd64] https://repo.skype.com/deb stable main" > /etc/apt/sources.list.d/skype-stable.list'

# teamviewer
sudo sh -c 'echo "deb https://linux.teamviewer.com/deb stable main" > /etc/apt/sources.list.d/teamviewer.list'

# smplayer
sudo add-apt-repository ppa:rvm/smplayer



sudo apt-get update


'