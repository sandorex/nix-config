{ config, my, ... }:

# common on all configuration except installers

{
  imports = [
    # import all the other modules
    ../default.nix
  ];

  networking.hostName = my.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  # NOTE: use en_GB so dates are correctly formatted
  i18n.defaultLocale = "en_GB.UTF-8";

  # every keyboard is US
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # enable automatic garbage collection
  my.gc.enable = true;

  dotfiles.enabled = with config.dotfiles.configs; [
    bin # contains scripts and stuff
  ];
}
