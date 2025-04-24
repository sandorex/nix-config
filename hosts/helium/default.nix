{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;

  # leave this be
  system.stateVersion = "24.05";
}
