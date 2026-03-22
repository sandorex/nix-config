{ flake, ... }:

{
  imports = [
    ./configuration.nix
    "${flake}/modules/base.nix"
  ];

  system.stateVersion = "24.11";
}
