{ config, lib, pkgs, pkgsUnstable, my, ... }:

{
  options = {
    my.extras.gui.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install extra gui applications";
    };

    my.extras.terminal.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install extra terminal applications";
    };
  };

  config =
    let
      extraGui = config.my.extras.gui.enable;
      extraTui = config.my.extras.terminal.enable;
    in
    {
      assertions = [
        {
          assertion = (extraGui && config.my.gui) || !extraGui;
          message = "Extra apps cannot be enabled without gui";
        }
      ];

      # fonts enabled if gui extras are
      fonts.packages = with pkgs; (lib.optionals extraGui [
        nerd-fonts.fira-code # proper font for terminal
      ]);
  
      environment.systemPackages = with pkgs; [
        # utilities
        git
        curl
        lm_sensors

        # common linux commands
        usbutils # lsusb
        bind.dnsutils # dig
        file # file
        unzip

        # used in scripts
        bc # cli calculator
      ]

      # it may pull in weird dependencies when i dont have a gui
      ++ (lib.optionals config.my.gui [
        libnotify     # notify-send
        wl-clipboard  # clipboard on wayland
      ])

      ## GUI APPS ##
      ++ (lib.optionals extraGui [
        kitty # proper terminal
        gparted # partitioning
        vlc # proper video player
        # varia # downloader + torrent # NOTE: currently broken package use flatpak instead
        easyeffects # mostly cause of volume normalization
        hardinfo2 # system information
        qalculate-qt # calculator
        audacious # music player
      ])

      ## TUI APPS ##
      ++ (lib.optionals extraTui [
        lsd

        pkgsUnstable.helix # proper editor

        python3
        libqalculate # qalc cli
        yt-dlp # youtube downloader

        nushell # the best shell
        buildah # container builder thingy

        shellcheck
      ]);

      # flatpaks to install (will not be installed if flatpak is disabled!)
      my.flatpak.install = [
        "io.github.giantpinkrobots.varia" # torrent + downloader
      ];

      # NOTE: localsend needs ports open so use this syntax
      # sharing files, links etc more secure variant of kdeconnect
      programs.localsend.enable = lib.mkDefault extraGui;

      dotfiles.enabled = with config.dotfiles.configs; [] ++ (lib.optionals extraGui [
        # setup kitty dotfiles, its awful without it
        kitty
        easyeffects
      ]);
    };
}
