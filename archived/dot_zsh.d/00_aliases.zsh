alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'

alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'

[[ "$(uname)" != "Darwin" ]] && {
  alias pbcopy='xsel --clipboard --input'
  alias open='xdg-open'
}

# General commands
alias k='kubectl'
alias bat='batcat'
alias vi='nvim'
alias c="chezmoi"
alias g="git"

# Ruby
alias bi='bundle install'
alias be='bundle exec'
