# Terminal title: show shortened path (e.g., /h/n/s/g/n/dotfiles)
# Each intermediate directory is abbreviated to its first character,
# while the last component is shown in full.
_short_path() {
  local dir="${PWD/#$HOME/~}"
  local parts=("${(@s:/:)dir}")
  local result=""
  local last=${#parts}

  for i in {1..$last}; do
    if [[ $i -eq $last ]]; then
      result+="${parts[$i]}"
    elif [[ -n "${parts[$i]}" ]]; then
      result+="${parts[$i][1]}/"
    else
      result+="/"
    fi
  done

  echo "$result"
}

_set_terminal_title() {
  print -Pn "\e]2;$(_short_path)\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_terminal_title
