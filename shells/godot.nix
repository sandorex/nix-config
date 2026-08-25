{ pkgs, ... }:

let
  # simple shell with godot and its export template
  godotShell = godot: pkgs.mkShell {
    name = godot.godot.name + "-shell";

    buildInputs = [
      godot.godot
      godot.export-template
    ];
  };
in
rec {
  # the latest
  godot = godot47;

  # NOTE define each version here!
  godot47 = godotShell pkgs.godotPackages_4_7;
  godot46 = godotShell pkgs.godotPackages_4_6;
  godot45 = godotShell pkgs.godotPackages_4_5;
}
