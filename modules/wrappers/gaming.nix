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

      # TODO idk which version is needed for bottles and hgl
      # NOTE must be full version or the automatic install will fail with multiple choices
      "runtime/org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/26.08" # mangohud for flatpak
    ];
  };
}
