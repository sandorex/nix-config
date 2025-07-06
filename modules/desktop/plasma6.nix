{ config, stable, lib, ... }:

{
  config = lib.mkMerge [
    (lib.mkIf config.my.kde.enable {
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

    (lib.mkIf config.my.sddm.enable {
      services.displayManager.sddm.enable = true;
    })
  ];
}
