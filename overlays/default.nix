{ ... }:

{
  # import my custom packages so they are available
  mypackages = final: _prev: import ../packages final.pkgs;
}
