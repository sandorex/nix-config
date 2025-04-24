{
  description = "Very experimental NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    stable = import nixpkgs { inherit system; config.allowUnfree = true; };
    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations.helium = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit stable unstable system home-manager;
        pkgs = stable;
        flake = self;
        hostname = "helium";
      };
      modules = [
        ./hosts/helium
        ./modules
        ./modules/plasma6.nix
        ./modules/shell.nix
        ./modules/printing.nix
      ];
    };
  };
}
