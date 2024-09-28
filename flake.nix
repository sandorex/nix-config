{
  description = "Very experimental NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
  
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgsUnstable, ... } @ inputs:
  let
    system = "x86_64-linux";
    stable = import nixpkgs { inherit system; config.allowUnfree = true; };
    unstable = import nixpkgsUnstable { inherit system; config.allowUnfree = true; };
  in {
    # note nixos is the hostname in this case
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit stable unstable system;
        flake = self;
        hostname = "nixos";
      };
      modules = [
        ./kvm/configuration.nix
        ./modules/bundle.nix
      ];
    };
  };
}
