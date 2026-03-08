{
  description = "nownabe's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      username = "nownabe";
      system = "x86_64-linux";
      overlay = final: prev: {
        aqua = final.callPackage ./packages/aqua.nix { };
        chikuwa = final.callPackage ./packages/chikuwa.nix { };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
      dotfilesDir = "/home/${username}/src/github.com/nownabe/dotfiles";
    in
    {
      homeConfigurations = {
        wsl = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username dotfilesDir; isWSL = true; };
          modules = [ ./home.nix ];
        };

        linux = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit username dotfilesDir; isWSL = false; };
          modules = [ ./home.nix ];
        };
      };
    };
}
