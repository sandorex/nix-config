{ stable, unstable, ... }:

# terminal tools and apps go here
{
  environment.systemPackages = with stable; [
    lsd
    starship
    nerd-fonts.fira-code

    unstable.neovim
    unstable.helix

    python3
    libqalculate # qalc cli
    yt-dlp # youtube downloader

    buildah
  ];
}
