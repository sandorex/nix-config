{ config, lib, pkgs, ... }:

{
  options.my.gaming.enable = lib.mkEnableOption "Enable gaming support (steam and stuff)";

  config = lib.mkIf config.my.gaming.enable {
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
      mangohud
    ];

    my.dotfiles.enabled = with config.my.dotfiles.configs; [
      # add mangohud config
      mangohud
    ];

    # changes scheduling should fix audio crackling
    security.rtkit.enable = true;

    # autoload ntsync on boot for proper proton experience
    boot.initrd.kernelModules = [ "ntsync" ];

    my.flatpak.install = [
      "com.usebottles.bottles"                        # general purpose proton/wine launcher
      "com.heroicgameslauncher.hgl"                   # GOG/Epic games launcher
      "net.davidotek.pupgui2"                         # proton-qt, manging proton versions
      "org.freedesktop.Platform.VulkanLayer.MangoHud" # mangohud for flatpak
    ];
  };
}
