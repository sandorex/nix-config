{ pkgs, ... } @ inputs:

# custom packages
{
  # mynix is in here cause i can debug it using `mynix run mynix ...`
  mynix = pkgs.callPackage ./mynix.nix inputs;
  installer = pkgs.callPackage ./installer.nix inputs;
  disky = pkgs.callPackage ./disky.nix inputs;
  irscrutinizer = pkgs.callPackage ./irscrutinizer.nix inputs;
  alass = pkgs.callPackage ./alass.nix inputs;
  QuickPiperAudiobook = pkgs.callPackage ./quick-piper-audiobook.nix inputs;
  nix-index = pkgs.callPackage ./nix-index.nix inputs;

  # TODO i don't think this should be tied to any python version
  pywayfire = pkgs.python3.pkgs.callPackage ./pywayfire.nix {};
}
