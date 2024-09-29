{...}:

# module that pulls all the modules for a workstation
{
  imports = [
    ./base.nix
    ./audio.nix
    ./printing.nix
    ./packages.nix
    ./virtualization.nix
    ./shell.nix
  ];
}
