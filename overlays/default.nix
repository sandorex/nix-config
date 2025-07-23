{ ... }:

{
  # import my custom packages os they are available
  mypackages = final: _prev: import ../packages final.pkgs;
}
