{
  description = "Very experimental NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # fetch public ssh keys from github
    ssh-keys-github = { url = "https://github.com/sandorex.keys"; flake = false; };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
    stable = import nixpkgs { inherit system; config.allowUnfree = true; };
    unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations = {
      helium = nixpkgs.lib.nixosSystem rec {
        specialArgs = {
          inherit stable unstable system home-manager;
          pkgs = stable;
          flake = self;
          hostname = "helium";
        };
        inherit system;
        modules = [ ./hosts/${specialArgs.hostname} ];
      };

      # installer with SSH enabled
      sshInstaller = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ ... }: {
            # users.users.nixos.password = "nixos";
            networking.hostName = "nixos-ssh-mini";
            services.openssh.enable = true;

            # use public ssh keys from github
            users.users.root.openssh.authorizedKeys.keys = (nixpkgs.lib.splitString "\n" (
              (builtins.readFile inputs.ssh-keys-github.outPath)
            ));

            # rename it so its different from regular nixos installer
            isoImage.isoBaseName = "nixos-ssh-mini";
            isoImage.volumeID = "nixos-ssh-mini";

            # bigger image but faster building
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            isoImage.makeUsbBootable = true;
            isoImage.makeEfiBootable = true;
          })
        ];
      };
    };
  };
}
