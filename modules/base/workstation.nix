{ lib, ... }:

{
  imports = [
    ./computer.nix
  ];

  system.switch.inhibitors.base = lib.mkForce "workstation";
}
