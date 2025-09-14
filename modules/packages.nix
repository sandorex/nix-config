{ config, lib, pkgs, pkgsUnstable, my, ... }:

{
  options = {
    my.apps.gui.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install extra gui applications";
    };

    my.apps.editor.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install editor and dependencies";
    };
  };

  config =
    let
      extraGui = config.my.apps.gui.enable;
      extraEditor = config.my.apps.editor.enable;
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
        git
        curl
        lm_sensors
        lsd
        bat
        python3
        shellcheck
        bc # cli calculator

        # encryption of secrets
        age
        sops

        # common linux commands
        usbutils # lsusb
        bind.dnsutils # dig
        file # file
        unzip
        unrar
      ]

      # it may pull in weird dependencies when i dont have a gui
      ++ (lib.optionals config.my.gui [
        libnotify     # notify-send
        wl-clipboard  # clipboard on wayland
      ])

      # basically editor and its dependencies
      ++ (lib.optionals extraEditor [
        pkgsUnstable.helix # proper editor
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
      ]);

      # flatpaks to install (will not be installed if flatpak is disabled!)
      my.flatpak.install = [] ++ (lib.optionals extraGui [
        "io.github.giantpinkrobots.varia" # torrent + downloader
      ]);

      # NOTE: localsend needs ports open so use this syntax
      # sharing files, links etc more secure variant of kdeconnect
      programs.localsend.enable = lib.mkDefault extraGui;

      dotfiles.enabled = with config.dotfiles.configs; [
        bin
        bash
        nano
        lsd # lsd config (colors mostly)
      ]

      # gui only stuff
      ++ (lib.optionals extraGui [
        # setup kitty dotfiles, its awful without it
        kitty
        easyeffects
      ])

      # editor, just add all of them..
      ++ (lib.optionals extraEditor [
        helix
        neovim
      ]);
    };

  # TODO set mime types for VLC at least
}
