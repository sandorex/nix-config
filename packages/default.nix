{ pkgs, ... }:

# custom packages
{
  irscrutinizer = pkgs.callPackage ./irscrutinizer.nix {};
}
