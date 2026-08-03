{ lib, ... }:

# contains all desktop options and imports all the files
{
  imports = [
    ./desktop/plasma6.nix
    ./desktop/cinnamon.nix
    ./desktop/swaywm.nix
    ./desktop/tuigreet.nix
    ./desktop/gnome.nix
    ./desktop/wayfire.nix
    ./desktop/cosmic.nix
  ];

  options = {
    my.gui = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Is GUI enabled (should be set by every desktop)";
    };
  };
}
