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
      
      # pulseaudioFull # more codecs, but idk if this is needed
    ];

    # make SSD great again!
    services.fstrim.enable = true;

    # reduce wait time for stop jobs
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';

    # audio stuff (use pipewire not pulseaudio)
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
