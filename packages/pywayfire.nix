{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pywayfire";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "pywayfire";
    tag = "v${version}";
    hash = "sha256-ZdylDSA3smo77MiG5xyNUA+ZGuYfT067QuBI1NuOXtQ=";
  };

  doCheck = false;

  pyproject = true;

  build-system = [
    setuptools
    wheel
  ];
}
