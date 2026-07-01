{ flake, config, pkgs, pkgsUnstable, ... }:

{
  imports = [
    flake.nixosModules.workstation

    ./networking.nix
    ./hardware-configuration.nix
    ./disks.nix
  ];

  system.stateVersion = "25.05";

  users.users.${config.my.user} = {
    isNormalUser = true;
    description = "${config.my.user}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout" # arduino
    ];
  };

  my = {
    zsh.enable = true;
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
    plasma-login-manager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    librewolf
    (vivaldi.override {
      commandLineArgs = "--ignore-gpu-blocklist --enable-zero-copy --password-store=kwallet6";
    })
    libreoffice
    krita
    orca-slicer
    cura-appimage
    qbittorrent
    arduino-ide

    ffmpeg
    yt-dlp  # youtube downloader
    nushell # the best shell
    buildah # container builder thingy
    gvisor  # container runtime thingy

    btop           # tui system monitor
    rofi           # for some scripts
    mpv            # scriptable media player
    proycon-wayout # wayland text widget thingy

    nvtopPackages.amd # gpu usage monitor
  ];

  # fonts.packages = with pkgs; [
  #   nerd-fonts.bigblue-terminal # funky pixel-y font
  # ];

  # # install zerotier but do not autostart it
  # services.zerotierone.enable = true;
  # systemd.services.zerotierone.wantedBy = lib.mkForce [];

  # manual sandboxing
  programs.firejail.enable = true;

  # shell session pool
  my.shpool = {
    enable = true;
    autostart = true;
  };

  # ext. monitor brightness control
  my.ddcutil.enable = true;

  my.flatpak.install = [
    "com.obsproject.Studio"
    "md.obsidian.Obsidian"  # notes
    "com.stremio.Stremio"

    "org.freecad.FreeCAD"   # CAD software
    "org.kde.kdenlive"      # video editor
  ];

  # apply flatpak permission overrides
  my.flatpak.overrides = [
    "global"
    "com.heroicgameslauncher.hgl"
    "com.usebottles.bottles"
    "io.github.Faugus.faugus-launcher"
    "net.lutris.Lutris"
  ];

  dotfiles.enabled = with config.dotfiles.configs; [
    zsh
    helix
    rofi
  ];

  # make 'nixos-rebuild build-vm' a lot faster
  virtualisation.vmVariant.virtualisation = {
    memorySize = 8192;
    cores = 6;
  };
}
