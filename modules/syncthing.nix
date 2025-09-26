{ config, lib, ... }:

{
  options.my = {
    syncthing.enable = lib.mkEnableOption "Enable syncthing";
  };

  config = lib.mkIf config.my.syncthing.enable {
    services.syncthing = {
      enable = true;
      relay.enable = false;
    };
  };
}
