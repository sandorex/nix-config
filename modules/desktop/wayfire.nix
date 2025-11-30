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

      kdePackages.kate # text editor

      # file manager
      kdePackages.dolphin
      kdePackages.dolphin-plugins
      kdePackages.qtsvg
      kdePackages.kio-fuse
      kdePackages.kio-extras
      kdePackages.kio-admin
      kdePackages.kservice

      waybar
      mako
      rofi
    ];

    programs.dconf.enable = true;

    # fixes dolphin mime types outside kde
    environment.etc."/xdg/menus/applications.menu".text =
    ''
      <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
      <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
      </Menu>
    '';
    # alternatively if the above breaks
    # builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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

    dotfiles.enabled = with config.dotfiles.configs; [
      wayfire
      waybar
    ];
  };
}
