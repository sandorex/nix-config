{ config, lib, pkgs, pkgsUnstable, my, ... }:

let
  gui = config.my.gui;
  base = config.my.apps.base.enable;
  standard = config.my.apps.standard.enable;
  terminal = config.my.apps.terminal.enable;

  dotfiles = config.my.apps.dotfiles.enable;
in
{
  options.my.apps = {
    # basically grouping software so i dont have to repeat it for each host
    base.enable = lib.mkEnableOption "Adds standard utilities available on most distros by default";
    standard.enable = lib.mkEnableOption "Adds terminal and some other nice things to have for computers";
    terminal.enable = lib.mkEnableOption "QoL packages for terminal meant for development computers";

    dotfiles.enable = lib.mkEnableOption "Should dotfiles be installed with the categories";
  };

  config = lib.mkMerge [
    (lib.mkIf (base) {
      environment.systemPackages = with pkgs; [
        git
        curl
        lm_sensors

        # encryption of secrets
        age
        sops

        # common preinstalled linux commands
        python3 # for scripting
        bc # cli calculator
        usbutils # lsusb
        bind.dnsutils # dig
        file # file
        unzip
        unrar

        # nice editor out of the box
        helix

        # search packages, nicer cli for nixos commands
        nh
      ]
      # it may pull in weird dependencies when i dont have a gui
      ++ (lib.optionals gui [
        libnotify     # notify-send
        wl-clipboard  # clipboard on wayland
      ]);

      dotfiles.enabled = with config.dotfiles.configs; lib.optionals (dotfiles) [
        git
        bin
        bash
        helix
      ];
    })

    (lib.mkIf (standard && gui) {
      # fonts enabled if gui extras are
      fonts.packages = with pkgs; [
        nerd-fonts.fira-code # proper font for terminal
      ];

      environment.systemPackages = with pkgs; [
        librewolf # browser
        kitty # proper terminal
        gparted # partitioning
        celluloid # actually proper video player (vlc is flaky)
        # varia # downloader + torrent # NOTE: currently broken package use flatpak instead
        hardinfo2 # system information
        qalculate-qt # calculator
        audacious # music player
        easyeffects # mostly cause of volume normalization
        mate.mate-system-monitor # the best system monitor
      ];

      # NOTE: localsend needs ports open so use this syntax
      programs.localsend.enable = true; # replacement for kdeconnect

      my.flatpak.install = [
        "io.github.giantpinkrobots.varia" # torrent + downloader
      ];

      dotfiles.enabled = with config.dotfiles.configs; lib.optionals (dotfiles) [
        kitty
        easyeffects
        # qalculate # TODO do i even have a rule for this?
      ];

      # TODO redo this
      # xdg.mime.defaultApplications = {
      #   # play all video in vlc
      #   "video/*" = "vlc.desktop";
      # };
    })

    (lib.mkIf (terminal) {
      environment.systemPackages = with pkgs; [
        lsd
        bat
        shellcheck
      ];

      dotfiles.enabled = with config.dotfiles.configs; lib.optionals (dotfiles) [
        lsd # theme so everything is readable
      ];
    })
  ];
}
