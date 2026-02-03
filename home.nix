{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    git
    ripgrep
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
  };
}
