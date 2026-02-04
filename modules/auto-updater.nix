{ config, pkgs, lib, my, ... }:

# automatic system updater
let
  serviceName = "mynix-automatic-update";
in
{
  options.my = {
    automatic-update.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Automatically update the system in background (will update the git repository if it exists)";
    };
  };

  config = lib.mkIf config.my.automatic-update.enable {
    systemd.user.timers.${serviceName} = {
      description = "NixOS Automatic Updater Timer";
      wantedBy = [ "timers.target" ];
      partOf = [ "${serviceName}.service" ];
      timerConfig = {
        OnCalendar = "Sunday";
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

      # TODO do i need set -eu?
      script = ''
        # update the git repository
        ${pkgs.git}/bin/git -C "${my.localPath}" pull --rebase

        ${pkgs.nix}/bin/nixos-rebuild --flake "${my.localPath}" boot

      '' + (if config.my.flatpak.enable then ''
        ${pkgs.flatpak}/bin/flatpak update --noninteractive --assumeyes
      '' else "");

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Restart = "on-failure";
        RestartSec = "30s";

        # prevent hogging all the resources
        CPUWeight = "20";
        IOWeight = "20";
      };
    };
  };
}
