{ config, lib, stable, unstable, hostname, ...}:

{
  # allow nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  # NOTE: use en_GB so dates are correctly formatted
  i18n.defaultLocale = "en_GB.UTF-8";

  # every keyboard is US
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # include sshd but do not autostart it if it was not explicitly enabled before here
  systemd.services.sshd.wantedBy = lib.mkIf config.services.openssh.enable (lib.mkForce []);
  services.openssh.enable = true;

  # enable bluetooth
  hardware.bluetooth.enable = true;

  # add useful packages for all machines
  environment.systemPackages = with stable; [
    git
    curl
    podman
    distrobox
    wl-clipboard
    lm_sensors
  ];

  # make SSD great again!
  services.fstrim.enable = true;
}
