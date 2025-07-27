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

      # theming
      kdePackages.breeze
      kdePackages.breeze-gtk
      kdePackages.breeze-icons
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
    ] ++ (with kdePackages; [
      ark
      dolphin
      dolphin-plugins
      okular
      gwenview
      kate # kate + kwrite

      # kwallet
      kwallet
      kwallet-pam
      kwalletmanager

      # dependencies
      ffmpegthumbs
      kdegraphics-thumbnailers
      kfilemetadata
      kimageformats
      kio
      kio-admin
      kio-extras
      kio-fuse
      kservice
      libheif
      plasma-workspace # huge but without it dolphin does not work
      qt6ct
      qtimageformats
      qtwayland
    ]);

    fonts.packages = with pkgs; [
      font-awesome # for waybar
      nerd-fonts.bigblue-terminal
    ];

    # fixes dolphin mime issues
    system.userActivationScripts.rebuildSycoca = ''
      # will be rebuilt automatically (taken from plasma6 nixos module)
      rm -fv $HOME/.cache/ksycoca*
    '';

    systemd.user.services.nixos-qt-theme = {
      description = "Sets up QT theming";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # render offscreen cause it has no access to the display
        export QT_QPA_PLATFORM=offscreen
        export XDG_MENU_PREFIX=plasma-

        # set the theme to breeze-dark
        ${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-lookandfeel -a org.kde.breezedark.desktop
      '';
    };

    # using uwsm so just use the services
    systemd.user.services.mako.enable = true;
    systemd.user.services.hyprpaper.enable = true; # does not have `programs.hyprpaper.enable` atm
    services.hypridle.enable = true;

    programs.hyprlock.enable = true;
    programs.uwsm.enable = true;
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # services.power-profiles-daemon.enable = lib.mkDefault true;
    services.udisks2.enable = true;   

    dotfiles.enabled = with config.dotfiles.configs; [
      hyprland
      waybar
      rofi
      mako
    ];

    security.polkit.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
      config = {
        hyprland = {
          default = [
            "hyprland"
            "kde"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        };
      };
      configPackages = lib.mkForce [ ];
    };

    # NOTE: UWSM seems to override XDG_MENU_PREFIX
    environment.variables = {
      # fixed dolphin mime issues
      XDG_MENU_PREFIX = "plasma-";
    };

    qt = {
      enable = true;
      # use qt theme from KDE (so i can use plasma-apply* scripts)
      platformTheme = "kde6";
    };

    programs.dconf = {
      enable = true;
      profiles.user.databases = [{
        settings = {
          # TODO does not work
          "org/gnome/desktop/interface" = {
            gtk-theme = "Adwaita:dark";
            color-scheme = "prefer-dark";
          };
        };
      }];
    };
  };
}
