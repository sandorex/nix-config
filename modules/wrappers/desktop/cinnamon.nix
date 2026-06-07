{ config, lib, ... }:

{
  options = {
    my.cinnamon.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Cinnamon desktop";
    };

    my.lightdm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use LightDM display manager";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.cinnamon.enable {
      my.gui = true;
      system.switch.inhibitors.desktop = lib.mkForce "cinnamon";

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
