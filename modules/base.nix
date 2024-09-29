{config, lib, stable, unstable, hostname, ...}:

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

  # do not autostart SSH server but create the systemd service unless already
  # enabled
  systemd.services.sshd.wantedBy = lib.mkIf config.services.openssh.enable (lib.mkForce []);

  # in case it was not enabled already enable it
  services.openssh.enable = true;

  # enable flatpak
  services.flatpak.enable = true;

  # TODO temp so there is a browser installed
  programs.firefox.enable = true;

  # add useful packages for all machines
  environment.systemPackages = with stable; [
    git
    curl
    podman
    distrobox
    wl-clipboard
    lm_sensors
  ];
}
