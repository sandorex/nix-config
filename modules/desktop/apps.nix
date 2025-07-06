{ stable, ... }:

# contains default graphical apps
{
  environment.systemPackages = with stable; [
    gparted # partitioning
    kitty # proper terminal
    vlc # proper video player
    varia # downloader + torrent
    easyeffects # mostly cause of volume normalization
    hardinfo2 # system information
    qalculate-qt # calculator
    audacious # music player
  ];

  # sharing files, links etc more secure variant of kdeconnect
  programs.localsend.enable = true;
}
