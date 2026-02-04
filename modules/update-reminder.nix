{ config, pkgs, lib, my, hostname, ... }:

# enables the helper script and update notifications
let
  # TODO this should be moved somewhere else but how do i access it??
  # override the script so it has proper localPath
  mynix = (my.packages.mynix.override {
    localPath = config.my.localPath;
    cfgHostname = hostname;
    thresholdDays = config.my.update-reminder.threshold;
  });

  serviceName = "update-reminder";
in
{
  options.my = {
    update-reminder.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Automatic reminder when user should update their system (gui only)";
    };

    update-reminder.threshold = lib.mkOption {
      default = 5;
      type = lib.types.ints.positive;
      description = "Threshold when to trigger update reminder";
    };
  };

  config = {
    environment.systemPackages = [ mynix ];

    # if gui then nag with notifications to update
    systemd.user.timers.${serviceName} = lib.mkIf config.my.update-reminder.enable {
      description = "Update Reminder Timer";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "${serviceName}.service" ];
      timerConfig = {
        OnCalendar = "Sunday";
        Persistent = "true";

        # do not start on boot
        RandomizedDelaySec = "30 minutes";
      };
    };

    systemd.user.services.${serviceName} = lib.mkIf config.my.update-reminder.enable {
      description = "Reminder to update";
      serviceConfig.Type = "simple";
      enableStrictShellChecks = true;
      script = ''
        # if not up to date just send a notification
        if ! last_update="$(${mynix}/bin/mn last-update)"; then
            ${pkgs.libnotify}/bin/notify-send -u critical -i update-low -a "mynix" "You should probably update" "Last update was on $last_update"
        fi
      '';
    };
  };
}
