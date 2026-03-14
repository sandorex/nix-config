{ config
, pkgs
, lib
, my
, ...
}:

# automatic system updater
let
  serviceName = "mynix-automatic-update";
in
{
  options.my.automatic-update = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Automatically update the system in background (will update the git repository if it exists)";
    };

    pull = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Pull latest from git repository, otherwise just updates inputs in local git repository";
    };
  };

  config = lib.mkIf config.my.automatic-update.enable {
    systemd.user.timers.${serviceName} = {
      description = "NixOS Automatic Updater Timer";
      wantedBy = [ "timers.target" ];
      partOf = [ "${serviceName}.service" ];
      timerConfig = {
        OnCalendar = "Sat,Wed 10:00";
        Persistent = "true";

        # do not start on boot
        RandomizedDelaySec = "30 minutes";
      };
    };

    systemd.user.services.${serviceName} = {
      description = "NixOS Automatic Updater";
      enableStrictShellChecks = true;

      after = [
        "network-online.target"
      ];

      wants = [ "network-online.target" ];

      script = ''
        set -eu

        if [[ "$(${pkgs.coreutils}/bin/readlink /nix/var/nix/profiles/system/sw)" != "$(${pkgs.coreutils}/bin/readlink /run/booted-system/sw)" ]]; then
          echo "Skipped, not the latest generation"
          exit 0
        fi

        ${pkgs.libnotify}/bin/notify-send -u critical -i update-low -a "mynix" "Updating the system" "The update will run in the background"

        cd "${my.localPath}"
        echo "Updating git repository"
        ${pkgs.git}/bin/git -C "${my.localPath}" pull --rebase
        ${pkgs.nix}/bin/nix flake update --commit-lock-file "$@"

        echo "Updating system"
        ${pkgs.nix}/bin/nixos-rebuild --flake "${my.localPath}" boot

      '' + (if config.my.flatpak.enable then ''
        echo "Updating flatpaks"
        ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
      '' else "");

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        # NOTE i do not want it to retry
        # Restart = "on-failure";
        # RestartSec = "30s";

        # prevent hogging all the resources
        CPUWeight = "20";
        IOWeight = "20";
      };
    };
  };
}
