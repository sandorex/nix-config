{ flake, ... }:

{
  # include all my packages as pkgs.my.xx
  # i did not want to do this but its least messy option for overriding my own packages
  my = final: prev: { my = flake.packages; };
}
