{ flake, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    "${flake}/modules/base.nix"
    "${flake}/modules/cinnamon.nix"
    "${flake}/modules/printing.nix"
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # TODO add initial password
  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      emacs
    ];
  };

  programs.firefox.enable = true;

  # leave this be
  system.stateVersion = "24.05";
}
