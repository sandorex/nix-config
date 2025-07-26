{ config, lib, pkgs, ... }:

let
  cfg = config.my.hyprland;
in
{
  options = {
    my.hyprland.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable Hyprland window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    my.gui = true;

    environment.systemPackages = with pkgs; [
      # using kwallet
      kdePackages.kwallet
      kdePackages.kwallet-pam
      kdePackages.kwalletmanager

      adwaita-icon-theme

      # theming
      kdePackages.breeze
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
      kdePackages.qt6ct
      libsForQt5.qt5ct
      nwg-look

      networkmanagerapplet # networkmanager applet and nm-connection-editor
      rofi-wayland # official rofi does not yet support wayland
      pavucontrol # gui for audio
      playerctl # controlling players
      overskride # gui for bluetooth (blueman sucks)
      libnotify # notifications
      waybar # the bar
      wev # key detection thingy
      grim # screenshot
      slurp # select region wayland (for grim)
      mako # notification system

      # hypr stuff
      hypridle
      hyprpaper
      hyprpolkitagent # polkit
      hyprshot

      # general applications
      kdePackages.kate
      kdePackages.gwenview
      kdePackages.dolphin
      kdePackages.ark
    ];

    fonts.packages = with pkgs; [
      font-awesome # for waybar
      nerd-fonts.bigblue-terminal
    ];

    programs.hyprland.enable = true;

    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "qt5ct";
    };

    programs.dconf.profiles.user = {
      databases = [{
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Adwaita";
          };

          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
      }];
    };
  };
}
