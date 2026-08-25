{ pkgs, ... }:

with pkgs;
mkShell {
  name = "platformio";

  buildInputs = [
    platformio-core
    avrdude
    clang-tools # LSP
  ];

  # TODO stdlib.h is missing
  # clangd_flags fixes `'gnu/stubs-32.h' file not found` error, this is a bit of a dirty fix but eh
  shellHook = ''
    export PLATFORMIO_CORE_DIR=$PWD/.platformio
    export CLANGD_FLAGS="--query-driver=$PLATFORMIO_CORE_DIR/packages/*/bin/*-gcc,/usr/bin/gcc"
    echo "Platformio devshell, note that platformio data is stored in the current directory!"
  '';
}
