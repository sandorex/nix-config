{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # cinnamon desktop using X11
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };
  
  # do not touch
  system.stateVersion = "24.05";
}
