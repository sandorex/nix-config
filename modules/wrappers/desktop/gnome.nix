{ config, pkgs, lib, ... }:

{
  options = {
    my.gnome.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable GNOME desktop";
    };

    my.gdm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use GDM display manager";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.gnome.enable {
      my.gui = true;
      system.switch.inhibitors.desktop = lib.mkForce "gnome";

      services.xserver.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # should make the qt apps have dark theme by default?
      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      programs.dconf.enable = true;
    })

    {
      services.displayManager.gdm.enable = config.my.gdm.enable;
    }
  ];
}
