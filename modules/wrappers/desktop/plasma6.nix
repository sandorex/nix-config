{ config, pkgs, lib, ... }:

{
  options = {
    my.kde.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable KDE Plasma desktop";
    };

    my.sddm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use SDDM display manager";
    };
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
  ];
}
