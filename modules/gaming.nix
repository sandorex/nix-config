{ config, lib, stable, ... }:

{
  options = {
    my.gaming.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable gaming support (steam and stuff)";
    };
  };

  config = lib.mkIf config.my.gaming.enable {
    programs.steam.enable = true;
    environment.systemPackages = with stable; [
      mangohud
    ];
  };
}
