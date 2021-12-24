#!/usr/bin/env bash

echo_g() {
  echo -e "\033[1;32m$*\033[m"
}

ensure_zplug() {
  if [[ ! -d "$HOME/.zplug" ]]; then
    git clone https://github.com/zplug/zplug "$HOME/.zplug"
  fi
}

ensure_symlinks() {
  local basedir name src dst

  basedir="$(cd "$(dirname "$0")" && pwd)"

  find "$basedir" -name ".*" | while read -r src; do
    name=$(basename "$src")

    [[ "$name" = ".git" ]] && continue
    [[ "$name" = ".gitignore" ]] && continue

    dst=$HOME/$name
    echo -n "$name : "

    if [[ -L $dst ]]; then
      echo "already exists 😘"
    else
      [[ -e $dst ]] && mv "$dst" "$dst.badkup"
      ln -s "$src" "$dst"
      echo_g "created new symbolic link! 🥳"
    fi
  done
}

ensure_zplug
ensure_symlinks
