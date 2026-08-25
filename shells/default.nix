{ pkgs, ... }:

{
  rust = pkgs.callPackage ./rust.nix {};
  android-studio = pkgs.callPackage ./android-studio.nix {};
  platformio = pkgs.callPackage ./platformio.nix {};
}
// import ./godot.nix { inherit pkgs; }
