{ pkgs, ... } @ inputs:

# custom packages
{
  mynix = pkgs.callPackage ./mynix.nix inputs;
  installer = pkgs.callPackage ./installer.nix inputs;
  disky = pkgs.callPackage ./disky.nix inputs;
  irscrutinizer = pkgs.callPackage ./irscrutinizer.nix inputs;
}
