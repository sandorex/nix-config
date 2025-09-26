{ config, lib, my, ... }:

{
  options.my.silent-boot.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = "Enables pretty and silent boot";
  };

  # TODO currently broken just make it show logo and nothing more
  config = lib.mkIf config.my.silent-boot.enable {
    assertions = [
      {
        assertion = config.boot.loader.systemd-boot.enable;
        message = "Silent boot is not tested without systemd-boot";
      }
    ];

    # boot.plymouth.enable = true;
    boot.plymouth = {
      enable = true;

      # using custom theme
      themePackages = [ my.packages.plymouth-mac-style ];
      theme = "mac-style";
    };

    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    boot.kernelParams = [ "quiet" "udev.log_level=0" ];
  };
}
