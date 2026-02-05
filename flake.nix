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
      pkgs = nixpkgs.legacyPackages.${system};

      mkHome = { isWSL }: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit username isWSL; };
        modules = [ ./home.nix ];
      };
    in
    {
      homeConfigurations = {
        wsl = mkHome { isWSL = true; };
        linux = mkHome { isWSL = false; };
      };
    };
}
