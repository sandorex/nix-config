{ config, lib, stable, unstable, hostname, ...}:

{
  options = {
    services.sshd.autostart = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Autostart SSH server";
    };
  };

  config = {
    # allow nix command and flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    # limit amount of configurations kept
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.grub.configurationLimit = 10;

    # automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

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

    # disable sshd autostart if not requested
    systemd.services.sshd.wantedBy = lib.mkIf (!config.services.sshd.autostart) (lib.mkForce []);
    services.sshd.enable = true;

    # sets up containers properly so podman works
    virtualisation.containers.enable = true;
    virtualisation.podman.enable = true;

    # appimage support
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # add useful packages for all machines
    environment.systemPackages = with stable; [
      git
      curl
      distrobox
      wl-clipboard
      lm_sensors
      micro
      usbutils # lsusb
      bind.dnsutils # dig
      file # file
    ];

    # make SSD great again!
    services.fstrim.enable = true;

    # reduce wait time for stop jobs
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };
}
