{ pkgs, username, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/git
    ./programs/nvim
    ./programs/claude
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";

    packages = with pkgs; [
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

      # Nix tools
      nil
      statix
      deadnix

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
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        addKeysToAgent = "yes";
      };
    };
  };

  services.ssh-agent.enable = true;
}
