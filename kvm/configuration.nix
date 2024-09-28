{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/plasma6.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };
  
  # do not touch
  system.stateVersion = "24.05";
}
