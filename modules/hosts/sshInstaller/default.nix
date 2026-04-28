{ flake, inputs, lib, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

    flake.nixosModules.installer
  ];

  users.users.nixos = {
    # password is required for ssh
    password = lib.mkForce "nixos";

    # installer has initial password set, this is to prevent warnings
    initialHashedPassword = lib.mkForce null;
  };

  networking.hostName = "nixos-ssh-mini";
  services.openssh.enable = true;

  # i want the base applications
  my.apps.base.enable = true;

  # use first usb serial automatically to allow installing via serial
  my.serial = {
    enable = true;
    path = "/dev/ttyUSB0";
    speed = 115200;
  };

  # rename it so its different from regular nixos installer
  image.baseName = lib.mkForce "nixos-ssh-mini";
  isoImage.volumeID = "nixos-ssh-mini";

  # bigger image but faster building
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
  isoImage.makeUsbBootable = true;
  isoImage.makeEfiBootable = true;
}
