{stable, unstable, ...}:

{
  programs.firefox.enable = true;

  environment.systemPackages = with stable; [
    unstable.neovim
    git
    curl
  ];
}
