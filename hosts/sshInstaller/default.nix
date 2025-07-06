{ inputs, stable, lib, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  users.users.nixos = {
    # password is required for ssh
    password = lib.mkForce "nixos";

    # installer has initial password set, this is to prevent warnings
    initialHashedPassword = lib.mkForce null;
  };

  networking.hostName = "nixos-ssh-mini";
  services.openssh.enable = true;

  # some useful packages
  environment.systemPackages = with stable; [
    git
    lm_sensors
    micro
  ];

  # # use public ssh keys from github
  # users.users.root.openssh.authorizedKeys.keys = (lib.splitString "\n" (
  #   (builtins.readFile inputs.ssh-keys-github.outPath)
  # ));

  # rename it so its different from regular nixos installer
  isoImage.isoBaseName = "nixos-ssh-mini";
  isoImage.volumeID = "nixos-ssh-mini";

  # bigger image but faster building
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.makeUsbBootable = true;
  isoImage.makeEfiBootable = true;
}
