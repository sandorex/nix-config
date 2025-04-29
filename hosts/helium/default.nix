{ flake, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    "${flake}/modules/base.nix"
    "${flake}/modules/flatpak.nix"
    "${flake}/modules/cinnamon.nix"
    "${flake}/modules/printing.nix"
  ];

  # leave this be
  system.stateVersion = "24.05";
}
