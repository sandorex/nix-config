{ config, lib, stable, unstable, ... }:

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
      gui = config.my.extras.gui.enable;
      tui = config.my.extras.terminal.enable;
    in
    {
      assertions = [
        {
          assertion = (gui && config.my.gui) || !gui;
          message = "Extra apps cannot be enabled without gui";
        }
      ];

      # fonts enabled if gui extras are
      fonts.packages = with stable; (lib.optionals gui [
        nerd-fonts.fira-code # proper font for terminal
      ]);
  
      environment.systemPackages = with stable; [
        # utilities
        git
        curl
        wl-clipboard
        lm_sensors

        # common linux commands
        usbutils # lsusb
        bind.dnsutils # dig
        file # file
        unzip

        # used in scripts
        libnotify # notify-send
        bc # cli calculator
      ]

      ## GUI APPS ##
      ++ (lib.optionals gui [
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
      ++ (lib.optionals tui [
        lsd
        starship

        unstable.helix # proper editor

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
      programs.localsend.enable = lib.mkDefault gui;

      dotfiles.enabled = with config.dotfiles.configs; [] ++ (lib.optionals gui [
        # setup kitty dotfiles, its awful without it
        kitty
        easyeffects
      ]);
    };
}
