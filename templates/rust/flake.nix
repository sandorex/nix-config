{
  description = "Rust starter flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit self;
      system = "x86_64-linux";

      # using glib
      pkgs = import nixpkgs { inherit system; };

      # using musl
      # pkgs = (import nixpkgs { inherit system; }).pkgsStatic;

      cargo_cfg = (builtins.fromTOML ./Cargo.toml);

      # for vergen_git2
      VERGEN_IDEMPOTENT = "1";
      VERGEN_GIT_SHA = if (self ? "rev") then (builtins.substring 0 7 self.rev) else "nix-dirty";
    in
    rec {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage rec {
        pname = argo_cfg.package.name;
        version = cargo_cfg.package.version;

        src = ./.;
        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        inherit VERGEN_IDEMPOTENT VERGEN_GIT_SHA;
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git
          cargo
        ];

        inherit VERGEN_IDEMPOTENT VERGEN_GIT_SHA;
      };
    };
}
