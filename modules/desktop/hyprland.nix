{ config, lib, stable, ... }:

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

    environment.systemPackages = with stable; [
      # using kwallet and so should be kinda compatible with kde plasma side by side
      kdePackages.kwallet
      kdePackages.kwallet-pam
      kdePackages.kwalletmanager

      rofi-wayland # official rofi does not yet support wayland
      playerctl # controlling players
      waybar # the bar
      grim # screenshot
      mako # notification system
    ];

    fonts.packages = with stable; [
      font-awesome # for waybar
    ];

    programs.hyprland.enable = true;

    xdg.portal.extraPortals = with stable; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };
}
