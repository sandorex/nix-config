{ pkgs, ... }:

with pkgs;
mkShell {
  name = "rust-basic-shell";

  buildInputs = [
    cargo
    rustc
    rustfmt
    rust-analyzer
    pre-commit
    rustPackages.clippy
  ];

  RUST_SRC_PATH = rustPlatform.rustLibSrc;
}
