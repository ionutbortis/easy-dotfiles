#!/bin/bash

DOCS_FOLDER="$( dirname "$(realpath -s "${BASH_SOURCE[0]}")" )"

DOC_FILES=(
  ./disclaimer.md
  ./quick-demo.md
  ./main-desktop-setup.md
  ./json-configuration.md
  ./shell-scripts.md
  ./automatic-actions.md
  ./tips-and-tricks.md
)

START_TOC="<!-- start TOC -->"
END_TOC="<!-- end TOC -->"

replace_section() {
  local start="$1" end="$2" target_file="$3" content_file="$4"

  sed -e "/$start/,/$end/ {//!d}; /$start/r $content_file" \
      -i "$target_file"

  sed -e "s/$start/&\n/" -e "s/$end/\n&/" \
      -i "$target_file"
}

replace_parts() {
  local file="$1"

  for part in header footer links; do
    local start="<!-- start $part -->"
    local end="<!-- end $part -->"

    echo "Replacing [ $part ] section in [ $file ]..."
    replace_section "$start" "$end" "$file" _"$part"_part.md 
  done
}

get_toc() {
  local file="$1"

  sed -n "/^$START_TOC/,/$END_TOC$/{//!p}" "$file" \
      | sed -e "s|#|$file#|" -e "/^[[:space:]]*$/d"
}

replace_main_toc() {
  local all_tocs="$1" target_file="./README.md"

  echo "Replacing main Table of Contents in [ $target_file ]..."
  replace_section "$START_TOC" "$END_TOC" "$target_file" "$all_tocs"
}

update_doc_files() {
  cd "$DOCS_FOLDER" || return

  local all_tocs=".all-tocs-temp"

  for file in "${DOC_FILES[@]}"; do
    replace_parts "$file"; echo
    get_toc "$file" >> "$all_tocs"
  done

  replace_main_toc "$all_tocs" && rm -f "$all_tocs"
}

create_no_emoji_docs() {
  cd "$DOCS_FOLDER" || return

  local no_emoji_folder="$DOCS_FOLDER/no-emoji"

  echo -e "\nCopying all main .md files to [ $no_emoji_folder ]..."
  rm -rf "$no_emoji_folder" && mkdir -p "$no_emoji_folder"
  cp ./*.md "$no_emoji_folder"/

  cd "$no_emoji_folder" || return
  rm -f ./*_part.md

  echo "Removing emojis from .md files..."
  sed -e "/^#/,/$/! s/:[a-z0-9_]*:$/./g" \
      -e "s/:[a-z0-9_]*://g" \
      -e "s/[ ]*,[ ]*/, /g" \
      -e "/\`\`\`/,/\`\`\`/! s/[ ]*\./\./g" \
      -e "/\`/,/\`/ s/\&\&\./\&\& \./g" \
      -e "s/!\./!/g" \
      -e "s/?\./?/g" \
      -e "s/?[ ]*)/?)/g" \
      -i ./*.md

  echo "Fixing links URL path..."
  sed -e "s|\.\./|\.\./\.\./|g" -i ./*.md

  echo "Fixing images URL path..."
  sed -e "s|\.\/images|\.\./images|g" -i ./*.md
}

update_copyright_year() {
  local current_year="$(date +'%Y')"

  echo -e "\nUpdating copyright year to [ $current_year ]..."
  sed -e "/^Copyright/,/$/ s/- [0-9]*/- $current_year/g" \
      -i "$DOCS_FOLDER"/../README.md
}

update_doc_files
create_no_emoji_docs
update_copyright_year
