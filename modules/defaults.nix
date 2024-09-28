{hostname, ...}:

{
  # allow nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  # NOTE: use en_GB so dates are correctly formatted
  i18n.defaultLocale = "en_GB.UTF-8";
}
