#!/bin/bash

JIDEA_HOME="$HOME/java-IDEs/jidea" && mkdir -p "$JIDEA_HOME"

desktop_file="$HOME/.local/share/applications/intellij-idea.desktop"

package="ideaIU-2022.2.3.tar.gz"

check_already_installed() {
  local jidea_folder="$(cd "$JIDEA_HOME" && ls -d -- *idea* 2> /dev/null)"

  [[ "$jidea_folder" ]] || return

  echo "[ WARN ] IntelliJ IDEA install is skipped since it already exists at [ $JIDEA_HOME/$jidea_folder ]"
  exit 0
}

download_package() {
  echo "Downloading jIDEA package [ $package ]..."
  wget -nv -t 5 "https://download.jetbrains.com/idea/$package" -O "$package"
}

install_package() {
  echo "Installing package to [ $JIDEA_HOME ]..."
  tar -zxf "$package" && rm "$package"

  local jidea_folder="$(ls -d -- *idea*)"
  mv "$jidea_folder" "$JIDEA_HOME"

  create_desktop_file "$jidea_folder"
}

create_desktop_file() {
  local jidea_folder="$1"

  if [[ -f "$desktop_file" ]]; then
    local backup_file="$desktop_file.$(date +'%Y-%m-%d_%H:%M:%S')"

    echo "[ WARN ] jIDEA desktop file already exists! [ $desktop_file ]"
    echo "[ WARN ] Creating backup file to [ $backup_file ]"
    cp "$desktop_file" "$backup_file"
  fi

  echo "Creating new desktop file [ $desktop_file ]..."

  bash -c "cat > $desktop_file << EOF
    [Desktop Entry]
    Type=Application
    Terminal=false
    Encoding=UTF-8
    Version=1.1
    X-Desktop-File-Install-Version=0.24

    Name=IntelliJ IDEA Ultimate
    Categories=Development;IDE;

    StartupWMClass=jetbrains-idea

    Exec=$JIDEA_HOME/$jidea_folder/bin/idea.sh
    Icon=$JIDEA_HOME/.icons/intellij-idea-icon.svg
EOF"

  sed "s/^[ \t]*//" -i "$desktop_file" 
}

check_already_installed
download_package
install_package
