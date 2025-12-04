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

    environment.variables = rec {
      # fixes QT app theming
      QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
      QT_QPA_PLATFORMTHEME_QT6 = QT_QPA_PLATFORMTHEME;
    };

    programs.dconf.enable = true;
  };
}
