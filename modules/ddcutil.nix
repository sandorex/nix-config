{ config, lib, pkgs, ... }:

# basically setups ddcutil to work properly
let
  cfg = config.my.ddcutil;
in
{
  options = {
    my.ddcutil.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable ddcutil for ext. monitor brightness control";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.i2c.enable = true;
    boot.kernelModules = ["i2c-dev"];

    environment.systemPackages = with pkgs; [ ddcutil ];
  };
}
