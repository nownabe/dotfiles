{ pkgs, username, ... }:

{
  imports = [
    ./programs/zsh
  ];

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
}
