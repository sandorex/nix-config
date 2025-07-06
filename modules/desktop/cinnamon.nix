{ config, lib, ... }:

{
  config = lib.mkMerge [
    (lib.mkIf config.my.cinnamon.enable {
      services.xserver.enable = true;
      services.libinput.enable = true;
      services.xserver.desktopManager.cinnamon.enable = true;
      services.displayManager.defaultSession = "cinnamon";
    })

    (lib.mkIf config.my.lightdm.enable {
      services.xserver.displayManager.lightdm.enable = true;
    })
  ];
}
