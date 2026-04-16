{ pkgs, ... }:

{
  rust = pkgs.callPackage ./rust.nix {};
  android-studio = pkgs.callPackage ./android-studio.nix {};
}
