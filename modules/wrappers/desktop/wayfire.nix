{ config, pkgs, lib, ... }:

let
  cursorName = "Breeze_Light";
  cursorSize = 24;
  cursorPkgs = with pkgs; [
      kdePackages.breeze
  ];
in
{
  options.my.wayfire = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Wayfire window manager";
    };

    python.enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable pywayfire for user python installation";
    };
  };

  config = lib.mkIf config.my.wayfire.enable {
    my.gui = true;
    system.switch.inhibitors.desktop = lib.mkForce "wayfire";

    programs.wayfire.enable = true;
    programs.wayfire.plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];

    # add pywayfire globally for scripts
    users.users.${config.my.user}.packages = lib.mkIf config.my.wayfire.python.enable [
      (pkgs.python3.withPackages (_: [
        pkgs.my.packages.pywayfire
      ]))
    ];

    environment.systemPackages = with pkgs; cursorPkgs ++ [
      adwaita-icon-theme

      waybar
      mako
      rofi

      xfce.thunar # file manager
      xviewer # image viewer
      mate.pluma # notepad
      mate.mate-system-monitor # system monitor
    ];

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
            gtk-theme = "default";
            color-scheme = "prefer-dark";
            cursor-size = lib.gvariant.mkUint32 cursorSize;
            cursor-theme = cursorName;
          };
        };
      }];
    };

    environment.variables = rec {
      XCURSOR_SIZE = cursorSize;
      XCURSOR_THEME = cursorName;
    };

    dotfiles.enabled = with config.dotfiles.configs; [
      wayfire
      waybar
      rofi
    ];
  };
}
