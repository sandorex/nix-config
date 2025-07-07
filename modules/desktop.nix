{ config, lib, stable, ... }:

# contains all desktop options and imports all the files
{
  imports = [
    ./desktop/plasma6.nix
    ./desktop/hyprland.nix
    ./desktop/cinnamon.nix
    ./desktop/tuigreet.nix
  ];

  options = {
    my.gui = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Is GUI enabled (should be set by every desktop)";
    };
  };
}
