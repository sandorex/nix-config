{
  description = "Python starter flake (EXPERIMENTAL)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit self;
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      pyproject = builtins.fromTOML ./pyproject.toml;

      pname = project_cfg.project.name;
      version = project_cfg.project.version;
    in
    rec {
      packages.${system}.default = buildPythonPackage rec {
        pname = pyproject.project.name;
        version = pyproject.project.version;

        src = ./.;

        # do not run tests
        doCheck = false;

        pyproject = true;

        build-system = [
          setuptools
          wheel
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          (python3.withPackages (p: with p; [
            (p.mkPythonEditablePackage
              pname = name;
              inherit version;

              root = "$REPO_ROOT"
            )
            pytest
          ]))
        ];
      };
    };
}
