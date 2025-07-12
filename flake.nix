{
  description = "Multi-host NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
  let
    # dotfiles information, static and shared across everything
    repo = rec {
      name = "nix-config";
      owner = "sandorex";
      url = "https://github.com/${owner}/${name}";
      branch = "dev";

      # name of local dotfiles, added to user's home
      localName = "${name}";
    };

    system = "x86_64-linux";
    stable = import nixpkgs { inherit system; config.allowUnfree = true; };
    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

    # consistent arguments passed to all modules
    createConfiguration = hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit stable unstable hostname repo inputs;
        flake = self;
      };

      inherit system;

      # let the default.nix handle everything
      modules = [ ./hosts/${hostname} ];
    };
  in {
    nixosConfigurations.thorium = createConfiguration "thorium";
    nixosConfigurations.helium = createConfiguration "helium";
    # nixosConfigurations.aorus = createConfiguration "aorus";
    # nixosConfigurations.sshInstaller = createConfiguration "sshInstaller";

  };
}
