rec {
  default = empty;

  empty = {
    path = ./empty;
    description = "Base flake template";
  };
  python = {
    path = ./python;
    description = "Python flake template (EXPERIMENTAL)";
  };
  rust = {
    path = ./rust;
    description = "Rust flake template";
  };
}
