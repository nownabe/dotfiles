export FZF_DEFAULT_OPTS="
  --color=bg+:236,bg:236,spinner:208,hl:208,info:208,prompt:208,fg:252,header:208
  --layout=reverse
  --height 50%
  --border
  --multi
  --cycle
  --walker-skip=.git,node_modules
  --history=${XDG_CACHE_HOME:-$HOME/.cache}/fzf/history
  --history-size=10000
  --bind=ctrl-j:down,ctrl-k:up
  --preview 'batcat --color=always --style=numbers --line-range :500 {}'"

export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range :500 {}'"

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
  --no-preview"

[[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/fzf" ]] || mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/fzf"

function fzf-ghq() {
  local target_dir
  target_dir=$(ghq list | fzf --no-multi --preview "batcat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.md")
  if [[ -n "$target_dir" ]]; then
    cd $(ghq root)/$target_dir
    zle accept-line
  fi
  zle reset-prompt
}
zle -N fzf-ghq
bindkey "^[" fzf-ghq

function fzf-cdr() {
  chpwd_recent_dirs -r "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/chpwd-recent-dirs"
  local selected_dir=$(cdr -l | sed 's/^[0-9]\+ \+//' | fzf --query "$LBUFFER" --preview 'tree -C {}')
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N fzf-cdr
bindkey '^O' fzf-cdr
