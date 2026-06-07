{ lib, ... }:

# common across all installers

{
  imports = [
    # import all the other modules
    ../default.nix
  ];

  system.switch.inhibitors.base = lib.mkForce "installer";
}
