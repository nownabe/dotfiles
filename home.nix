{ pkgs, username, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/git
    ./programs/nvim
    ./programs/claude
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Version control
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
    claude-code

    # Cloud
    awscli2
    google-cloud-sdk
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  services.ssh-agent.enable = true;
}
