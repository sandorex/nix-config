{ config, lib, pkgs, ... }:

{
  options = {
    my.printing.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable printing support";
    };

    my.scanning.enable = lib.mkOption {
      default = config.my.printing.enable;
      type = lib.types.bool;
      description = "Enable scanner support";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.printing.enable {
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        # Xerox 3010
        foo2zjs
      ];
    })

    (lib.mkIf config.my.scanning.enable {
      hardware.sane.enable = true;

      # allow permissions for main user to use the scanner
      users.users.${config.my.user}.extraGroups = [ "scanner" ];
    })
  ];
}
