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

      # name of local dotfiles, appended to user's home
      localName = "${name}";
    };

    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

    # this is a shortcut so i dont have to use flake.outputs.packages.x86_64-linux.something
    my = {
      packages = import ./packages { inherit pkgs; };
      overlays = import ./overlays {};
    };

    # consistent arguments passed to all modules
    createConfiguration = hostname: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit pkgsUnstable inputs hostname repo my;
        flake = self;
      };

      inherit system;

      modules = [
        {
          # allow unfree
          nixpkgs.config.allowUnfree = true;

          # allow nix command and flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # disable channels
          nix.channel.enable = false;
        }

        # default.nix imports wanted modules or nothing if desired
        ./hosts/${hostname}
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

    packages.${system} = my.packages // packageImageAliases;

    overlays = my.overlays;
  };
}
