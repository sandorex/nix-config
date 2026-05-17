{ pkgs, ... }:

{
  rust = pkgs.callPackage ./rust.nix {};
  android-studio = pkgs.callPackage ./android-studio.nix {};
}
// import ./godot.nix { inherit pkgs; }
