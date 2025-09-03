{ lib, config, pkgs, ... }:

# enable automatic serial console on specific usb port with usb to serial adapter
# useful for debugging headless machines

let
  serviceName = "usb-getty";

  enable = config.my.serial.enable;
  path = config.my.serial.path;
  term = config.my.serial.term;
  speed = config.my.serial.speed;
in
{
  options.my.serial = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enabled serial console when plugged in";
    };

    path = lib.mkOption {
      default = null;
      type = with lib.types; nullOr str;
      description = "Path to serial device (/dev/serial/by-path/ or /dev/serial/by-id/)";
      example = "/dev/serial/by-path/pci-0000:01:00.0-usb-0:4:1.0-port0";
    };

    term = lib.mkOption {
      default = "vt102";
      type = lib.types.str;
      description = "TERM var for the serial connection";
      example = "xterm-256color";
    };

    speed = lib.mkOption {
      default = 9600;
      type = lib.types.ints.unsigned;
      description = "Baud rate of the serial connection";
      example = 115200;
    };
  };

  config = lib.mkIf enable {
    assertions = [
      {
        assertion = path != null;
        message = "Serial console path cannot be null";
      }
    ];

    # path unit that automatically starts the service if the device is plugged in
    systemd.paths.${serviceName} = {
      pathConfig = {
        PathExists = path;
        Unit = "${serviceName}.service";
      };

      wantedBy = ["multi-user.target"];
    };

    # service that starts only if the device is plugged in, so it can be started on boot
    systemd.services.${serviceName} = {
      description = "On-demand serial console on usb-to-serial";
      wantedBy = ["getty.target"];

      unitConfig = {
        # do not start if the serial does not exist
        ConditionPathExists = path;
        After = [
          "systemd-user-sessions.service"
          "plymouth-quit-wait.service"
          "getty-pre.target"
        ];
      };

      serviceConfig = {
        ExecStart = "-${pkgs.util-linux}/bin/agetty -o '-- \\u' -L -w ${ lib.removePrefix "/dev/" path } ${toString speed} ${term}";
        Type = "idle";
        Restart = "no";
        RestartSec = 0;
        TTYPath = path;
        TTYReset = "yes";
        TTYDisallocate = "yes";
        TTYVHangup = "yes";
        KillMode = "process";
        IgnoreSIGPIPE = "no";
        SendSIGHUP = "yes";

        UnsetEnvironment = "LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION";
      };
    };
  };
}
