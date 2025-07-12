{ config, lib, stable, ... }:

{
  options = {
    my.sway.enable = lib.mkEnableOption "swaywm";
  };

  config = lib.mkIf config.my.sway.enable {
    my.gui = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    environment.systemPackages = with stable; [
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
      waybar # the bar
      wev # key detection thingy
      grim # screenshot
      slurp # select region wayland (for grim)
      mako # notification system
      swaybg # sway background tool

      jq

      # general applications
      kdePackages.kate
      kdePackages.gwenview
      kdePackages.dolphin
      kdePackages.ark
    ];

    fonts.packages = with stable; [
      # waybar
      font-awesome
      nerd-fonts.bigblue-terminal
    ];

    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "qt5ct";
    };

    environment.sessionVariables = {
      # fix for dolphin MIME types being empty
      XDG_MENU_PREFIX = "plasma-";
      # TODO define other XDG directories as sway does not

      XDG_PICTURES_DIR = "/home/${config.my.user}/Pictures";
    };

    environment.etc."/xdg/menus/plasma-applications.menu".text = builtins.readFile "${stable.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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
