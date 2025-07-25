{ pkgs, ... }:

# custom packages
{
  mynix = pkgs.callPackage ./mynix.nix {};
  irscrutinizer = pkgs.callPackage ./irscrutinizer.nix {};
}
