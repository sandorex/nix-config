{ stable, ... }:

# this module provides gui applications that are common across all devices
{
  environment.systemPackages = with stable; [
    gparted # partitioning
    kitty # proper terminal
    vlc # proper video player
    varia # downloader + torrent
    easyeffects # mostly cause of volume normalization
  ];
}
