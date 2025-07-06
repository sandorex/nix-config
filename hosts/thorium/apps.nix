{ stable, unstable, ... }:

# apps here
{
  environment.systemPackages = with stable; [
    rofi-wayland # official rofi does not yet support wayland
    vivaldi
    librewolf
    libreoffice
    krita
    orca-slicer
    qbittorrent
  ]
  
  ## terminal stuff
  ++ [
    unstable.neovim
  ];
}
