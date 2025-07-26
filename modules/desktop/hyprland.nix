{ config, lib, pkgs, ... }:

let
  cfg = config.my.hyprland;

  # taken from plasma6 nixos module
  activationScript = ''
    # will be rebuilt automatically
    rm -fv $HOME/.cache/ksycoca*
  '';
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

    system.userActivationScripts.rebuildSycoca = activationScript;
    systemd.user.services.nixos-rebuild-sycoca = {
      description = "Rebuild KDE system configuration cache";
      wantedBy = [ "graphical-session-pre.target" ];
      serviceConfig.Type = "oneshot";
      script = activationScript;
    };

    programs.hyprland.enable = true;

    services.power-profiles-daemon.enable = lib.mkDefault true;
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

    environment.variables = {
      # fixed dolphin mime issues
      XDG_MENU_PREFIX = "plasma-";
    };

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
