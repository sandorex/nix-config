{ stable, ... }:

{
  imports = [
    ./pipewire.nix
  ];

  environment.systemPackages = with stable; [
    # using kwallet and so should be kinda compatible with kde plasma side by side
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.kwalletmanager

    waybar
    grim
    wl-clipboard
    mako # notification system
  ];

  programs.hyprland.enable = true;
}
