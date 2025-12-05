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
      adwaita-icon-theme
      kdePackages.breeze # breeze cursor

      waybar
      mako
      rofi

      thunar # file manager
      xviewer # image viewer
      mate.pluma # notepad
      mate.mate-system-monitor # system monitor
    ];

    programs.dconf.enable = true;

    fonts.packages = with pkgs; [
      # waybar
      font-awesome
      nerd-fonts.bigblue-terminal
    ];

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [{
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
      }];
    };

    environment.variables = rec {
      XCURSOR_SIZE = 24;
      XCURSOR_THEME = "Breeze_Light";
    };

    dotfiles.enabled = with config.dotfiles.configs; [
      wayfire
      waybar
      rofi
    ];
  };
}
