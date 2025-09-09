{ config, lib, pkgs, ... }:

{
  options = {
    my.printing.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable printing support";
    };
  };

  config = lib.mkIf config.my.printing.enable {
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      # Xerox 3010
      foo2zjs
    ];
  };
}
