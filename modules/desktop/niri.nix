{ stable, ... }:

{
  # keep kde stuff hopefully from breaking
  services.displayManager.sddm.enable = true;
  environment.systemPackages = with stable; [
    kdePackages.kwallet
    kdePackages.sddm
    waybar
  ];

  programs.niri.enable = true;
}
