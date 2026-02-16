{ pkgs, username, ... }:

{
  imports = [
    ./programs/zsh
    ./programs/git
    ./programs/nvim
    ./programs/claude
    ./programs/wezterm
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
      nodejs
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
      gnumake
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
      includes = [ "~/.ssh/config.local" ];
      matchBlocks."*" = {
        addKeysToAgent = "yes";
      };
    };

    mise = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  services.ssh-agent.enable = true;
}
