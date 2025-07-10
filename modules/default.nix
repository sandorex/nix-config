{ config, lib, stable, unstable, hostname, repo, ...}:

{
  imports = [
    ./flatpak.nix
    ./printing.nix
    ./virtualization.nix
    ./gaming.nix
    ./bluetooth.nix
    ./pipewire.nix
    ./garbage.nix
    ./gaming.nix
    ./packages.nix
    ./desktop.nix
    ./ddcutil.nix
    ./dotfiles.nix
    ./helpers.nix
  ];

  options = {
    my.user = lib.mkOption {
      default = repo.owner;
      type = lib.types.str;
      description = "Main user of the system";
    };

    my.localPath = lib.mkOption {
      default = "/home/${config.my.user}/${repo.localName}";
      type = lib.types.str;
      description = "Path on host where dotfiles are stored";
      readOnly = true;
    };

    my.repoURL = lib.mkOption {
      default = repo.url;
      type = lib.types.str;
      description = "URL to the git repository";
      readOnly = true;
    };

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

    # allows running binaries not built for nix
    programs.nix-ld.enable = true;

    # appimage support
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    # add useful packages for all machines
    environment.systemPackages = with stable; [
      git
      curl
      wl-clipboard
      lm_sensors
      micro
      usbutils # lsusb
      bind.dnsutils # dig
      file # file
      nh # nix cli helper
    ];

    # disable sshd autostart if not requested
    systemd.services.sshd.wantedBy = lib.mkIf (!config.services.sshd.autostart) (lib.mkForce []);
    services.sshd.enable = true;

    # make SSD great again!
    services.fstrim.enable = true;

    # reduce wait time for stop jobs
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };
}
