{ config, lib, ... }:

# basically sddm display manager
{
  config = lib.mkIf config.my.sddm.enable {
    services.displayManager.sddm.enable = true;
  };
}
