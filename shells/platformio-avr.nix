{ pkgs, ... }:

with pkgs;
mkShell {
  name = "platformio-avr";

  buildInputs = [
    platformio-core
    avrdude
  ];
}
