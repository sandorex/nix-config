{ config, lib, stable, ... }:

# contains all desktop options and imports all the files
{
  imports = [
    ./desktop/plasma6.nix
    ./desktop/hyprland.nix
    ./desktop/cinnamon.nix
  ];

  options = {
    ## desktops ##
  
    my.kde.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable KDE Plasma desktop";
    };

    my.hyprland.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Hyprland window manager";
    };

    my.cinnamon.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Cinnamon desktop";
    };

    my.gui = lib.mkOption {
      default = (config.my.kde.enable || config.my.hyprland.enable || config.my.cinnamon.enable);
      type = lib.types.bool;
      readOnly = true;
      description = "Is GUI enabled";
    };

    ## greeters ##

    my.tuigreet.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use tuigreet greetd greeter";
    };

    my.sddm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use SDDM display manager";
    };

    my.lightdm.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use LightDM display manager";
    };
  };
}
