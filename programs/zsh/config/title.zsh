# Terminal title: show git-root-relative path with root dir name.
# In a git repo: "dotfiles" (at root) or "dotfiles/programs/zsh" (in subdir)
# Outside a git repo: shortened path (e.g., ~/s/g/n/dotfiles)
_title_path() {
  local toplevel
  toplevel=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$toplevel" ]]; then
    local root_name="${toplevel:t}"
    local rel="${PWD#$toplevel}"
    echo "${root_name}${rel}"
  else
    # Fallback: shortened path for non-git directories
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
  fi
}

_set_terminal_title() {
  print -Pn "\e]2;\ue795 $(_title_path)\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_terminal_title
