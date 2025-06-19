{ config, lib, stable, unstable, hostname, ...}:

{
  options = {
    services.sshd.autostart = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Autostart SSH server";
    };

    nix.gc.keep-generations = lib.mkOption {
      default = 15;
      type = lib.types.ints.positive;
      description = "Keep this number of generations from being garbage collected";
    };
  };

  config = {
    # allow nix command and flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    # allows running binaries not built for nix
    programs.nix-ld.enable = true;

    # automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      # do not delete generations as that is done using nix-gen-gc
      # options = "--delete-older-than 15d";
    };

    # clean up generations before garbage collecting
    systemd.services.nix-gc.wants = [ "nix-gen-gc.service" ];

    # automatic generation garbage collection
    systemd.services.nix-gen-gc = {
      description = "NixOS Generation Garbage Collector";
      script = "exec ${config.nix.package.out}/bin/nix-env -vvvv --profile /nix/var/nix/profiles/system --delete-generations +${toString config.nix.gc.keep-generations}";
      serviceConfig.Type = "oneshot";
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
      # fuse-overlayfs is much faster than the alternative
      # https://github.com/containers/podman/issues/16541
      fuse-overlayfs # podman
      nh # nix cli helper
    ];

    # make SSD great again!
    services.fstrim.enable = true;

    # reduce wait time for stop jobs
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };
}
