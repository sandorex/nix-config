{ lib, ... }:

# specific base for all servers

{
  imports = [
    ./computer.nix
  ];

  system.switch.inhibitors.base = lib.mkForce "server";
}
