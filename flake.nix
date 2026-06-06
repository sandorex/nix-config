{
  description = "Multi-host NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
  let
    # dotfiles information, static and shared across everything
    repo = rec {
      name = "nix-config";
      owner = "sandorex";
      url = "https://github.com/${owner}/${name}";
      branch = "main";

      # name of local dotfiles, appended to user's home
      localName = "${name}";
    };

    flake = self;
    system = "x86_64-linux";

    secrets = import ./modules/secrets.nix "/nix-secret";

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };

    pkgsUnstable = import nixpkgs-unstable {
      inherit system;

      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };

    # consistent arguments passed to all modules
    createConfiguration = hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit pkgsUnstable inputs flake repo hostname secrets;
      };

      inherit system;

      modules = [
        {
          nixpkgs.overlays = [
            # allow access to my own packages
            (final: prev: { my = flake.packages.${system}; })
          ];

          # allow unfree
          nixpkgs.config.allowUnfree = true;

          # allow nix command and flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # disable channels
          nix.channel.enable = false;
        }

        # default.nix imports wanted modules or nothing if desired
        ./modules/hosts/${hostname}
      ];
    };

    configurations = [
      "thorium"
      "helium"
      "sshInstaller"
    ];

    # creates package for each config that has an image type set, basically all
    # installers are going to have a package that builds them
    packageImageAliases = nixpkgs.lib.pipe configurations [
      # check if it has defined image format
      (builtins.filter (x: self.nixosConfigurations.${x}.config.system.build ? image))

      # name it appropriately
      (builtins.map (name: {
        inherit name;
        value = self.nixosConfigurations.${name}.config.system.build.image;
      }))

      # convert it to an attrs
      builtins.listToAttrs
    ];
  in {
    nixosConfigurations = nixpkgs.lib.genAttrs configurations createConfiguration;

    nixosModules = {
      # NOTE these are shortcuts to the base modules
      workstation = ./modules/base/workstation.nix;
      laptop = ./modules/base/laptop.nix;
      server = ./modules/base/server.nix;
      installer = ./modules/base/installer.nix;
    };

    packages.${system} = (import ./packages { inherit repo flake pkgs; }) // packageImageAliases;

    overlays = import ./overlays { inherit repo flake; };

    templates = import ./templates;

    devShells.${system} = import ./shells { inherit repo flake pkgs; };
  };
}
