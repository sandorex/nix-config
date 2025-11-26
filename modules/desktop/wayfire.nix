{ config, pkgs, lib, ... }:

{
  options = {
    my.wayfire.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Wayfire window manager";
    };
  };

  config = lib.mkIf config.my.wayfire.enable {
      my.gui = true;

      programs.wayfire.enable = true;
      programs.wayfire.plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];

      environment.systemPackages = with pkgs; [
        # theming
        gnome-tweaks
        adwaita-icon-theme
        nwg-look
        kdePackages.qt6ct
        libsForQt5.qt5ct
        wcm # config gui for wayfire

        kdePackages.kate # text editor
        kdePackages.dolphin # file manager

        waybar
        mako
        rofi
      ];

      # should make the qt apps have dark theme by default?
      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      programs.dconf.enable = true;
    };
}
