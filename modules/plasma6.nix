{stable, ...}:

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # remove some unecessary bloat
  environment.plasma6.excludePackages = with stable.kdePackages; [
    kamoso
    kmail
    kmousetool
    kolourpaint
    akregator
    neochat
  ];

  programs.dconf.enable = true;
}
