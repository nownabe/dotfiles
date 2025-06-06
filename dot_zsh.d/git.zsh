gitwt() {
  # Show help directly
  if [[ $1 == "-h" || $1 == "--help" ]]; then
    git-wt-helper -h
    return
  fi

  local dest
  dest=$(git-wt-helper "$@") || return
  echo "DEST: $dest"
  [[ -n $dest ]] && cd "$dest"
}

alias wt=gitwt

