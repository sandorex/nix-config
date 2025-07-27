{ flake, config, lib, pkgs, hostname, repo, my, ... }:

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

  config =
    let
      # override the script so it has proper localPath
      mynix = (my.packages.mynix.override {
        localPath = config.my.localPath;
        inherit hostname;
      });

      updateReminderService = "update-reminder";
    in
    {
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

      # disable sshd autostart if not requested
      systemd.services.sshd.wantedBy = lib.mkIf (!config.services.sshd.autostart) (lib.mkForce []);
      services.sshd.enable = true;

      # make SSD great again!
      services.fstrim.enable = true;

      # reduce wait time for stop jobs
      systemd.extraConfig = ''
        DefaultTimeoutStopSec=15s
      '';

      # add the helper script
      environment.systemPackages = [ mynix ];

      # if gui then nag with notifications to update
      systemd.user.timers.${updateReminderService} = lib.mkIf config.my.gui {
        description = "Update Reminder Timer";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "${updateReminderService}.service" ];
        timerConfig.OnCalendar = "8:00";
        timerConfig.Persistent="true";
      };

      systemd.user.services.${updateReminderService} = lib.mkIf config.my.gui {
        description = "Reminder to update";
        serviceConfig.Type = "simple";
        enableStrictShellChecks = true;

        # just call the helper script
        script = ''
          # if not up to date just send a notification
          if ! last_update="$(${mynix}/bin/mynix up-to-date)"; then
              ${pkgs.libnotify}/bin/notify-send -i update-low -a "mynix" "You should probably update" "Last update was $last_update"
          fi
        '';
      };

      virtualisation.vmVariant = {
        # as the password is set non-declaratively you cannot login by default
        users.users.${config.my.user}.initialPassword = "password";

        # TODO this is only for thorium, helium does not have this amount of ram
        virtualisation = {
          memorySize = 8192;
          cores = 6;
        };

        # use dotfiles from nix store, as the repository is not cloned in the vm
        my.localPath = "${flake}";

        # disable flatpak as it wont have space to install it in the vm
        my.flatpak.enable = lib.mkForce false;
      };
    };
}
