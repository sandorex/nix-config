{stable, unstable, ...}:

# extra packages useful on workstations
{
  environment.systemPackages = with stable; [
    zellij
    unstable.neovim

    # apps
    kitty
    mpv-unwrapped
  ];
}
