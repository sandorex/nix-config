{ config, lib, pkgs, pkgsUnstable, my, ... }:

{
  imports = [
    ../../modules/base/workstation.nix

    ./hardware-configuration.nix
    ./disks.nix
  ];

  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    printing.enable = true;
    gaming.enable = true;
    flatpak.enable = true;
    apps = {
      base.enable = true;
      standard.enable = true;
      terminal.enable = true;

      dotfiles.enable = true;
    };

    update-reminder.enable = true;

    pipewire.enable = true;
    kde.enable = true;
    sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    librewolf
    vivaldi
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

    rofi # for some scripts

    pkgsUnstable.neovim # stable version has broken treesitter
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
  ];

  dotfiles.enabled = with config.dotfiles.configs; [
    zsh
    helix
  ];

  # make 'nixos-rebuild build-vm' a lot faster
  virtualisation.vmVariant.virtualisation = {
    memorySize = 8192;
    cores = 6;
  };
}
