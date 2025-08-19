{ flake, config, lib, pkgs, my, ... }:

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
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  my = {
    libvirtd.enable = true;
    podman.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    apps = {
      gui.enable = true;
      editor.enable = true;
    };

    kde.enable = true;
    sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    librewolf
    libreoffice
    krita
    orca-slicer
    cura-appimage
    qbittorrent
    my.packages.irscrutinizer
    arduino-ide

    zellij # terminal multiplexer

    yt-dlp # youtube downloader
    nushell # the best shell
    buildah # container builder thingy

    rofi-wayland # for some scripts
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

  dotfiles.enabled = with config.dotfiles.configs; [
    zsh
  ];

  # make 'nixos-rebuild build-vm' a lot faster
  virtualisation.vmVariant.virtualisation = {
    memorySize = 8192;
    cores = 6;
  };
}
