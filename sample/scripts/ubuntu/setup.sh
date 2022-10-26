#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../../../scripts/common/vars.sh"
  source "$script_folder/../../../scripts/common/utils.sh"

}; sources

add_flatpak_support() {
  sudo apt-get install flatpak -y
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

add_software_repos() {
  echo "Adding extra software repos (chrome, vscode, atom, skype, etc.)..."

  sudo apt install -y wget gpg apt-transport-https ca-certificates curl gnupg-agent software-properties-common
 
  # chrome
  wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

  # vscode
  wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
      | sudo tee /etc/apt/sources.list.d/vscode.list
  rm -f packages.microsoft.gpg

  # atom
  wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
  echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list

  # skype
  curl https://repo.skype.com/data/SKYPE-GPG-KEY | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/repo.skype.com.gpg >/dev/null
  echo "deb [arch=amd64] https://repo.skype.com/deb stable main" | sudo tee /etc/apt/sources.list.d/skypeforlinux.list

  # teamviewer
  wget -qO - https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | sudo apt-key add -
  echo "deb https://linux.teamviewer.com/deb stable main" | sudo tee /etc/apt/sources.list.d/teamviewer.list

  # smplayer
  sudo add-apt-repository ppa:rvm/smplayer -y

  sudo apt update -y
}

replace_snap_firefox() {
  sudo snap remove firefox

  sudo add-apt-repository ppa:mozillateam/ppa -y
  sudo apt update -y

  echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox

  echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

  sudo apt install firefox -y --allow-downgrades
}

run_apt_clean() {
  sudo apt autoremove -y
}

add_flatpak_support
add_software_repos
replace_snap_firefox
run_apt_clean
