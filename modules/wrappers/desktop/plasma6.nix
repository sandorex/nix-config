{ config, pkgs, lib, ... }:

{
  options.my = {
    kde.enable = lib.mkEnableOption "Enable KDE Plasma desktop";
    sddm.enable = lib.mkEnableOption "Use SDDM display manager";
    plasma-login-manager.enable = lib.mkEnableOption "Use Plasma Login Manager display manager";
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.kde.enable {
      my.gui = true;
      system.switch.inhibitors.desktop = lib.mkForce "kde";

      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true;

      # remove some unecessary bloat
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        kamoso
        kmail
        kmousetool
        kolourpaint
        akregator
        neochat
        plasma-systemmonitor
      ];

      programs.dconf.enable = true;
    })

    {
      services.displayManager.sddm.enable = config.my.sddm.enable;
    }

    {
      services.displayManager.plasma-login-manager.enable = config.my.plasma-login-manager.enable;
    }
  ];
}
