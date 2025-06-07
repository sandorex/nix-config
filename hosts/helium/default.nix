{ flake, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    "${flake}/modules/base.nix"
    "${flake}/modules/flatpak.nix"
    "${flake}/modules/desktop/cinnamon.nix"
    "${flake}/modules/desktop/apps.nix"
    "${flake}/modules/printing.nix"
    "${flake}/modules/bluetooth.nix"
  ];

  # leave this be
  system.stateVersion = "24.05";
}
