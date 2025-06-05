{ stable, unstable, ... }:

# graphical apps here
{
  environment.systemPackages = with stable; [
    vivaldi
    librewolf
    libreoffice
    krita
    orca-slicer
    qbittorrent
  ];
}
