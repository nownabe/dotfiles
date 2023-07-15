#!/usr/bin/env bash

echo_g() {
  echo -e "\033[1;32m$*\033[m"
}

ensure_directories() {
  [[ -e "$HOME/.cache" ]] || mkdir -p $HOME/.cache
  [[ -e "$HOME/.cache/shell" ]] || mkdir -p $HOME/.cache/shell
}

ensure_zplug() {
  if [[ ! -d "$HOME/.zplug" ]]; then
    git clone https://github.com/zplug/zplug "$HOME/.zplug"
  fi
}

ensure_symlinks() {
  local basedir name src dst dstdir

  basedir="$(cd "$(dirname "$0")" && pwd)"

  find "$basedir" -type f | grep -v /.git/ | while read -r src; do
    name=$(basename "$src")

    [[ "$name" = ".gitignore" ]] && continue
    [[ "$name" = "setup.sh" ]] && continue
    [[ "$name" = "README.md" ]] && continue

    dst=$HOME/$name
    echo -n "$dst : "

    if [[ -L $dst ]]; then
      echo "already exists 😘"
    else
      [[ -e $dst ]] && mv "$dst" "$dst.badkup"

      dstdir="$(dirname "$dst")"
      if [[ ! -e "$dstdir" ]]; then
        mkdir -p "$dstdir"
      fi

      ln -s "$src" "$dst"
      echo_g "created new symbolic link! 🥳"
    fi
  done
}

ensure_directories
ensure_zplug
ensure_symlinks
