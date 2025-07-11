{ flake, config, lib, stable, unstable, ... }:

{
  imports = [
    ./configuration.nix

    "${flake}/modules"
  ];

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
    extras = {
      gui.enable = true;
      terminal.enable = true;
    };
    helpers.enable = true;

    hyprland.enable = true;
    tuigreet = {
      enable = true;
      autologin.command = "hyprland";
    };
  };

  # add plain plasma specialisation as backup
  specialisation.plasma.configuration.my = {
    hyprland.enable = lib.mkForce false;
    tuigreet.enable = lib.mkForce false;

    kde.enable = true;
    sddm.enable = true;
  };

  environment.systemPackages = with stable; [
    # enable codecs and force kwallet6 regardless of desktop
    (stable.vivaldi.override {
      proprietaryCodecs = true;
      commandLineArgs = "--password-store=kwallet6";
    })
    librewolf
    libreoffice
    krita
    orca-slicer
    cura-appimage
    qbittorrent

    ## terminal stuff
    unstable.neovim
  ];

  # ext. monitor brightness control
  my.ddcutil.enable = true;

  dotfiles = {};
}
