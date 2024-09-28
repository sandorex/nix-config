{stable, unstable, ...}:

# add extra packages, usually used on workspaces
{
  environment.systemPackages = with stable; [
    zellij
    unstable.neovim

    # apps
    kitty
    mpv-unwrapped
  ];
}
