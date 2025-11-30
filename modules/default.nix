{ config, lib, repo, inputs, ... }:

# imports all modules which do not enable anything by default!
# so this file is imported by every configuration including installers

{
  imports = [
    ./flatpak.nix
    ./printing.nix
    ./virtualization.nix
    ./gaming.nix
    ./bluetooth.nix
    ./pipewire.nix
    ./garbage.nix
    ./gaming.nix
    ./apps.nix
    ./desktop.nix
    ./ddcutil.nix
    ./dotfiles.nix
    ./serial.nix
    ./mynix.nix
    ./sshd.nix
    ./disky.nix
  ];

  options = {
    my.user = lib.mkOption {
      default = repo.owner;
      type = lib.types.str;
      description = "Main user of the system";
    };

    my.localPath = lib.mkOption {
      default = "/home/${config.my.user}/${repo.localName}";
      type = lib.types.str;
      description = "Path on host where dotfiles are stored";
    };

    my.repoURL = lib.mkOption {
      default = repo.url;
      type = lib.types.str;
      description = "URL to the git repository";
      readOnly = true;
    };
  };

  # common across all configurations
  config =
  let
    dnsServers = [
      "1.1.1.1" # cloudflare
      "9.9.9.9" # quad9
      "8.8.8.8" # google dns
    ];
  in
  {
    # use same version of nixpkgs for `nix shell` and other commands
    nix.registry.nixpkgs.flake = inputs.nixpkgs;
    nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;

    # all propriatery firmware
    hardware.enableAllFirmware = true;

    # allows running binaries not built for nix
    programs.nix-ld.enable = true;

    # appimage support
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # make SSD great again!
    services.fstrim.enable = true;

    # use proper dns servers
    networking.nameservers = lib.mkDefault dnsServers;
    networking.networkmanager.insertNameservers = lib.mkDefault dnsServers;

    # reduce wait time for stop jobs
    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "15s";
    };

    # settings for build-vm
    virtualisation.vmVariant = {
      # as the password is set non-declaratively you cannot login by default
      users.users.${config.my.user}.initialPassword = "password";

      # mount dotfiles in the vm when testing
      virtualisation.sharedDirectories.dotfiles = {
        source = config.my.localPath;
        target = config.my.localPath;
      };

      # disable flatpak as it wont have space to install it in the vm
      my.flatpak.enable = lib.mkForce false;
    };
  };
}
