{ config, pkgs, lib, ... }:

{
  options = {
    my.cosmic.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable COSMIC desktop";
    };
  };

  config = lib.mkIf config.my.cosmic.enable {
    my.gui = true;

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    environment.cosmic.excludePackages = with pkgs; [
      # kinda laggy and meh, try again on release
      pkgs.cosmic-player
      pkgs.cosmic-term
      pkgs.cosmic-edit
    ];

    environment.systemPackages = with pkgs; [
      # all for that sweet breeze cursor
      kdePackages.breeze
    ];

    environment.variables = rec {
      # fixes QT app theming
      QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
      QT_QPA_PLATFORMTHEME_QT6 = QT_QPA_PLATFORMTHEME;

      XCURSOR_SIZE = 24;
      XCURSOR_THEME = "Breeze_Light";
    };

    programs.dconf.enable = true;
  };
}
