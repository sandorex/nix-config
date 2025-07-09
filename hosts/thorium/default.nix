{ config, flake, stable, unstable, ... }:

{
  imports = [
    ./configuration.nix

    "${flake}/modules"
  ];

  my.user = "sandorex";

  users.users.${config.my.user} = {
    isNormalUser = true;
    description = "${config.my.user}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # use zsh by default
  users.defaultUserShell = stable.zsh;
  programs.zsh.enable = true;

  my = {
    libvirtd.enable = true;
    podman.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    apps.terminal = true;
    helpers.enable = true;

    kde.enable = true;
    hyprland.enable = true;
    tuigreet = {
      enable = true;
      # autologin into KDE for now
      autologin.command = "startplasma-wayland";
    };
  };

  environment.systemPackages = with stable; [
    vivaldi
    librewolf
    libreoffice
    krita
    orca-slicer
    qbittorrent

    ## terminal stuff
    unstable.neovim
  ];

  # ext. monitor brightness control
  my.ddcutil.enable = true;

  dotfiles.clone.enable = true;
  dotfiles.dotfiles = {
  };
}
