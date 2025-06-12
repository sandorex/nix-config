{ stable, ... }:

{
  # keep kde stuff hopefully from breaking
  services.displayManager.sddm.enable = true;

  # enable wayland mode for sddm
  services.displayManager.sddm.wayland.enable = false;

  environment.systemPackages = with stable; [
    kdePackages.kwallet
    kdePackages.sddm
    waybar
  ];

  programs.niri.enable = true;
}
