{ config, lib, pkgs, ... }:

{
  options = {
    my.sway.enable = lib.mkEnableOption "swaywm";
  };

  config = lib.mkIf config.my.sway.enable {
    my.gui = true;
    system.switch.inhibitors.desktop = lib.mkForce "swaywm";

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # TODO
    # # Allows storage devices to be controlled over D-Bus
    # services.udisks2.enable = true;
    # # Used as an abstraction over udisks2 by file managers
    # services.gvfs.enable = true;
    #
    # services.gnome.gnome-keyring.enable = true;
    # programs.seahorse.enable = true;
    # programs.evince.enable = true;

    # app secrets (alternative to KWallet)
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      # theming
      kdePackages.breeze-icons
      kdePackages.qt6ct
      yaru-theme # GTK theme
      adwaita-icon-theme
      nwg-look
      qt6Packages.qtstyleplugin-kvantum # kvantum theming

      networkmanagerapplet # networkmanager applet and nm-connection-editor
      rofi # official rofi does not yet support wayland
      pavucontrol # gui for audio
      playerctl # controlling players
      overskride # gui for bluetooth (blueman sucks)
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
      thunar           # file manager
      lxqt.pcmanfm-qt  # file manager2

      # the shell
      quickshell
    ];

    # TODO requires manually configuring qt6ct to use kvantum and breeze-icons, in kvantum manager set KvGnomeDark
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    # set gnome theme declaratively
    programs.dconf.profiles.user = {
      databases = [{
        lockAll = true;
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = "Yaru-purple-dark";
            icon-theme = "Yaru-purple-dark";
            color-scheme = "default";
          };
        };
      }];
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
        XDG_PROJECTS_DIR="${home}/Projects";
        XDG_VIDEOS_DIR="${home}/Videos";
      };

    # programs.dconf = {
    #   enable = true;
    #   profiles.user.databases = [{
    #     lockAll = true;
    #     settings = {
    #       # NOTE: this was copied from KDE Plasma session using
    #       # `dconf dump /org/gnome/desktop/interface`
    #       "org/gnome/desktop/interface" = {
    #         gtk-theme = "Breeze-Dark";
    #         icon-theme = "breeze-dark";
    #         color-scheme = "prefer-dark";
    #         font-antialiasing="grayscale";
    #         font-hinting="slight";
    #         font-name="Noto Sans,  10";
    #         font-rgba-order="rgb";
    #       };
    #     };
    #   }];
    # };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        # wlr portal does not implement most things
        pkgs.xdg-desktop-portal-gtk
      ];
      # xdgOpenUsePortal = true # https://github.com/NixOS/nixpkgs/issues/160923
    };
  };
}
