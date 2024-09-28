{stable, unstable, ...}:

{
  programs.firefox.enable = true;

  environment.systemPackages = with stable; [
    git
    curl
    podman
    distrobox
    wl-clipboard
    lm_sensors
  ];
}
