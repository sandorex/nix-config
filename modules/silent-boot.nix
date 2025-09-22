{ config, lib, ... }:

{
  options.my.silent-boot.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = "Enables pretty and silent boot";
  };

  # TODO i do not know if this works on only with systemd-boot
  config = lib.mkIf config.my.silent-boot.enable {
    boot.plymouth.enable = true;
    boot.plymouth.theme = "bgrt";
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelParams = [ "quiet" "udev.log_level=0" ];
  };
}
