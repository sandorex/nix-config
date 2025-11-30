{ pkgs, ... } @ inputs:

# custom packages
{
  # mynix is in here cause i can debug it using `mynix run mynix ...`
  mynix = pkgs.callPackage ./mynix.nix inputs;
  installer = pkgs.callPackage ./installer.nix inputs;
  disky = pkgs.callPackage ./disky.nix inputs;
  irscrutinizer = pkgs.callPackage ./irscrutinizer.nix inputs;
}
