{ config, lib, pkgs, ... }:

{
  options = {
    my.printing = lib.mkOption {
      default = config.my.gui; # include automatically if gui
      type = lib.types.bool;
      description = "Enable printing support";
    };
  };

  config = {
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      # Xerox 3010
      foo2zjs
    ];
  };
}
