{ config, lib, pkgs, ... }:

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
      waybar # the bar
      wev # key detection thingy
      grim # screenshot
      slurp # select region wayland (for grim)
      mako # notification system
      swaybg # sway background tool

      jq

      # general applications
      qimgv            # image viewer
      kdePackages.kate # text editor
      file-roller      # archive manager
      musicpod         # music player
      xfce.thunar      # file manager
    ];

    fonts.packages = with pkgs; [
      # waybar
      font-awesome
      nerd-fonts.bigblue-terminal
    ];

    qt = {
      enable = true;
      style = "breeze";
      platformTheme = "qt5ct";
    };

    services.udisks2.enable = true;

    # define XDG directories as sway does not set them
    environment.sessionVariables =
      let
        home = "/home/${config.my.user}";
      in
      {
        XDG_DESKTOP_DIR="${home}/Desktop";
        XDG_DOCUMENTS_DIR="${home}/Documents";
        XDG_DOWNLOAD_DIR="${home}/Downloads";
        XDG_MUSIC_DIR="${home}/Music";
        XDG_PICTURES_DIR="${home}/Pictures";
        XDG_PUBLICSHARE_DIR="${home}/Public";
        XDG_TEMPLATES_DIR="${home}/Templates";
        XDG_VIDEOS_DIR="${home}/Videos";
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
