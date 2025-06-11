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

gitroot() {
  cd "$(git rev-parse --show-toplevel)" || return
}

git() {
  # Check if the first argument is 'wt'
  if [[ $1 == "wt" ]]; then
    shift  # Remove 'wt' from the arguments
    gitwt "$@"
  elif [[ $1 == "root" ]]; then
    gitroot
  else
    command git "$@"
  fi
}
