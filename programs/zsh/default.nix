{ pkgs, ... }:

{
  xdg.configFile = {
    "zsh/completion.zsh".source = ./config/completion.zsh;
    "zsh/cdr.zsh".source = ./config/cdr.zsh;
    "zsh/fzf.zsh".source = ./config/fzf.zsh;
    "zsh/git.zsh".source = ./config/git.zsh;
    "zsh/utils.zsh".source = ./config/utils.zsh;
    "zsh/wsl.zsh".source = ./config/wsl.zsh;
    "zsh/mise.zsh".source = ./config/mise.zsh;
    "zsh/path.zsh".source = ./config/path.zsh;

    # Pure prompt (uses Nix store path interpolation)
    "zsh/prompt.zsh".text = ''
      # Pure prompt setup
      # Source pure prompt from Nix store
      fpath+=(${pkgs.pure-prompt}/share/zsh/site-functions)

      autoload -U promptinit
      promptinit
      prompt pure
    '';
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    defaultKeymap = "emacs";

    history = {
      size = 1000000;
      save = 1000000;
      path = "$HOME/.cache/zsh/history";
      extended = true;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;
    };

    # setopt options
    setOptions = [
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "AUTO_MENU"
      "EXTENDED_GLOB"
      "HIST_REDUCE_BLANKS"
      "CORRECT"
      "INTERACTIVE_COMMENTS"
      "NO_BEEP"
    ];

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
      # Additional key bindings (not available in programs.zsh options)
      bindkey "^P" history-beginning-search-backward
      bindkey "^N" history-beginning-search-forward

      # Load config files from ~/.config/zsh/
      for file in "$HOME/.config/zsh"/*.zsh; do
        [[ -f "$file" ]] && source "$file"
      done
    '';
  };
}
