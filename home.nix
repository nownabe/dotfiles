{ pkgs, ... }:

{
  home.username = "nownabe";
  home.homeDirectory = "/home/nownabe";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    git
    ripgrep
  ];

  programs.home-manager.enable = true;
}
