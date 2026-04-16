{ pkgs, ... }:

with pkgs;
mkShell {
  name = "android-studio-shell";

  buildInputs = [
    android-studio
  ];
}
