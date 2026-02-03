{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Version control
    git
    gh
    ghq

    # Languages & runtimes
    go
    lua
    python3
    ruby
    deno
    bun

    # Package managers
    uv

    # CLI tools
    ripgrep
    fzf
    yq-go
    jq
    curl
    zip
    unzip
    gnupg

    # Cloud
    awscli2
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 1000000;
      save = 1000000;
      path = "$HOME/.cache/zsh/history";
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    historySubstringSearch.enable = true;

    shellAliases = {
      # ls/grep with color
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";

      # File listing
      la = "ls -a";
      ll = "ls -l";
      lla = "ls -al";

      # Safety
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";

      # Linux clipboard
      pbcopy = "xsel --clipboard --input";
      open = "xdg-open";

      # General commands
      k = "kubectl";
      bat = "batcat";
      vi = "nvim";
      c = "chezmoi";
      g = "git";

      # Ruby
      bi = "bundle install";
      be = "bundle exec";
    };

    initExtra = ''
      #--------------------------------
      # Key bindings
      #--------------------------------
      bindkey -e
      bindkey "^P" history-beginning-search-backward
      bindkey "^N" history-beginning-search-forward

      #--------------------------------
      # Options
      #--------------------------------
      setopt auto_cd
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt auto_menu
      setopt extended_glob
      setopt hist_reduce_blanks
      setopt correct
      setopt interactive_comments
      unsetopt beep

      #--------------------------------
      # Completion
      #--------------------------------
      zstyle ':completion:*:default' menu select=1
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

      #--------------------------------
      # cdr (recent directories)
      #--------------------------------
      autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
      add-zsh-hook chpwd chpwd_recent_dirs
      zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/zsh/chpwd-recent-dirs"
      zstyle ':chpwd:*' recent-dirs-max 1000
      zstyle ':chpwd:*' recent-dirs-default true
      zstyle ':chpwd:*' recent-dirs-pushd true
      zstyle ':completion:*:*:cdr:*:*' menu selection
      zstyle ':completion:*' recent-dirs-insert both

      #--------------------------------
      # FZF
      #--------------------------------
      export FZF_DEFAULT_OPTS="
        --color=bg+:236,bg:236,spinner:208,hl:208,info:208,prompt:208,fg:252,header:208
        --layout=reverse
        --height 50%
        --border
        --multi
        --cycle
        --walker-skip=.git,node_modules
        --history=$HOME/.cache/fzf/history
        --history-size=10000
        --bind=ctrl-j:down,ctrl-k:up
        --preview 'batcat --color=always --style=numbers --line-range :500 {}'"

      export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range :500 {}'"

      export FZF_CTRL_R_OPTS="
        --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
        --color header:italic
        --header 'Press CTRL-Y to copy command into clipboard'
        --no-preview"

      [[ -d "$HOME/.cache/fzf" ]] || mkdir -p "$HOME/.cache/fzf"

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
        chpwd_recent_dirs -r "$HOME/.cache/zsh/chpwd-recent-dirs"
        local selected_dir=$(cdr -l | sed 's/^[0-9]\+ \+//' | fzf --query "$LBUFFER" --preview 'tree -C {}')
        if [ -n "$selected_dir" ]; then
          BUFFER="cd ''${selected_dir}"
          zle accept-line
        fi
        zle clear-screen
      }
      zle -N fzf-cdr
      bindkey '^O' fzf-cdr

      #--------------------------------
      # Git worktree helpers
      #--------------------------------
      gitwt() {
        if [[ $1 == "-h" || $1 == "--help" ]]; then
          git-wt-helper -h
          return
        fi

        if [[ $1 == "-b" ]]; then
          shift
          local git_common_dir
          if git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null); then
            cd "$git_common_dir/.."
          else
            echo "Not in a git repository" >&2
            return 1
          fi
          return
        fi

        if [[ ! -d "''${PWD:-}" ]]; then
          echo "Current directory does not exist. Use 'cd' to move to a valid directory." >&2
          return 1
        fi

        local dest
        dest=$(git-wt-helper "$@") || return
        [[ -n $dest ]] && cd "$dest"
      }

      gitroot() {
        cd "$(git rev-parse --show-toplevel)" || return
      }

      git() {
        if [[ $1 == "wt" ]]; then
          shift
          gitwt "$@"
        elif [[ $1 == "root" ]]; then
          gitroot
        else
          command git "$@"
        fi
      }

      #--------------------------------
      # Utility functions
      #--------------------------------
      COLOR_RESET="\033[0m"
      COLOR_INFO="\033[1;32m"
      COLOR_WARN="\033[1;33m"
      COLOR_ERROR="\033[1;31m"

      echo_info() { echo -e "''${COLOR_INFO}$*''${COLOR_RESET}"; }
      echo_warn() { echo -e "''${COLOR_WARN}$*''${COLOR_RESET}"; }
      echo_error() { echo -e "''${COLOR_ERROR}$*''${COLOR_RESET}"; }

      #--------------------------------
      # WSL2
      #--------------------------------
      if grep -qi "WSL2" /proc/version 2>/dev/null; then
        echo_info "🐧 Running inside WSL2"
        export IS_WSL="true"
        export GPG_TTY="$(tty)"
        export BROWSER="/usr/bin/wslview"
      fi

      #--------------------------------
      # mise & aqua (for existing projects)
      #--------------------------------
      if [[ -f "$HOME/.local/bin/mise" ]]; then
        eval "$($HOME/.local/bin/mise activate zsh)"
      fi

      export PATH="''${AQUA_ROOT_DIR:-''${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
      export AQUA_GLOBAL_CONFIG="''${AQUA_GLOBAL_CONFIG:-''${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml}"

      #--------------------------------
      # PATH
      #--------------------------------
      export PATH="$HOME/bin:$PATH"
    '';
  };
}
