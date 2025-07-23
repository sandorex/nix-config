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
      "dialout" # for arduino
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

    kde.enable = true;
    sddm.enable = true;
  };

  environment.systemPackages = with stable; [
    librewolf
    libreoffice
    krita
    orca-slicer
    cura-appimage
    qbittorrent

    ## terminal stuff
    unstable.neovim
  ];

  # manual sandboxing
  programs.firejail.enable = true;

  # ext. monitor brightness control
  my.ddcutil.enable = true;

  my.flatpak.install = [
    "com.obsproject.Studio"
    "md.obsidian.Obsidian"  # notes
    "com.stremio.Stremio"

    "org.freecad.FreeCAD"   # CAD software
    "org.kde.kdenlive"      # video editor
    "com.vivaldi.Vivaldi"   # browser
  ];
}
