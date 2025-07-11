{ config, stable, lib, ... }:

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

      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true;

      # remove some unecessary bloat
      environment.plasma6.excludePackages = with stable.kdePackages; [
        kamoso
        kmail
        kmousetool
        kolourpaint
        akregator
        neochat
      ];

      programs.dconf.enable = true;
    })

    {
      services.displayManager.sddm.enable = config.my.sddm.enable;
    }
  ];
}
