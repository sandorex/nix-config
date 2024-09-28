{stable, unstable, ...}:

{
  programs.firefox.enable = true;

  environment.systemPackages = [
    unstable.neovim
    stable.git
  ];
}
