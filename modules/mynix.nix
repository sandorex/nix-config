{ config, pkgs, lib, my, hostname, ... }:

# enables the helper script and update notifications
let
  # override the script so it has proper localPath
  mynix = (my.packages.mynix.override {
    localPath = config.my.localPath;
    inherit hostname;
  });

  serviceName = "update-reminder";
in
{
  environment.systemPackages = [ mynix ];

  # if gui then nag to update
  systemd.timers.${serviceName} = lib.mkIf config.my.gui {
    description = "Update Reminder Timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "${serviceName}.service" ];
    timerConfig.OnCalendar = "8:00";
    timerConfig.Persistent="true";
  };

  systemd.services.${serviceName} = lib.mkIf config.my.gui {
    description = "Reminder to update";
    serviceConfig.Type = "simple";

    script = ''
      set -eo pipefail

      last_update="$(${mynix}/bin/mynix up-to-date)"
      code=$?
      if [[ $code -eq 1 ]]; then
          ${pkgs.libnotify}/bin/notify-send -u critical -i update-low -a "mynix" "You should probably update" "Last update was $last_update"
      fi
    '';
  };
}
