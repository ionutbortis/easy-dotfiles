#!/bin/bash

sources() {
  local script_folder="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

  source "$script_folder/../../../scripts/common/vars.sh"
  source "$script_folder/../../../scripts/common/utils.sh"

}; sources

update_dnf_config() {
  echo "Updating dnf configuration..."

  local dnf_conf_file="/etc/dnf/dnf.conf"
  local temp_conf_file="/tmp/dnf.conf"

  cp "$dnf_conf_file" "$temp_conf_file"

  replace_config_property "$temp_conf_file" fastestmirror True
  replace_config_property "$temp_conf_file" max_parallel_downloads 5
  replace_config_property "$temp_conf_file" defaultyes True
  replace_config_property "$temp_conf_file" keepcache True

  sudo bash -c "cp $temp_conf_file $dnf_conf_file"
  rm "$temp_conf_file"
}

run_system_update() {
  echo "Running dnf update..."

  sudo dnf update -y
}

enable_rpm_fusion() {
  echo "Enabling RPM fusion..."

  sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

  sudo dnf groupupdate core -y
}

add_flatpak_support() {
  echo "Adding flatpak/flathub support..."

  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

add_software_repos() {
  echo "Adding extra software repos (vscode, skype, etc.)..."

  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

  sudo dnf config-manager -y --add-repo https://repo.skype.com/rpm/stable/skype-stable.repo

  dnf check-update -y
}

install_media_codecs() {
  echo "Installing media codecs..."

  sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
  sudo dnf groupupdate -y sound-and-video
}

install_xprop() {
  echo "Installing missing xprop..."

  sudo dnf install -y xprop
}

update_dnf_config
run_system_update
enable_rpm_fusion
add_flatpak_support
add_software_repos
install_media_codecs
install_xprop
