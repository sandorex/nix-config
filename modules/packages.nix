{ config, lib, stable, unstable, ... }:

# contains all packages (gui and tui)
{
  # TODO rename to extras.enable and extras.terminal.enable
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
      extraGUI = config.my.extras.gui.enable;
      extraTUI = config.my.extras.terminal.enable;
      extraTUIWithGUI = config.my.extras.terminal.enable && config.my.gui;
    in
    {
      assertions = [
        {
          assertion = (config.my.extras.gui.enable && config.my.gui) || !config.my.extras.gui.enable;
          message = "Extra apps cannot be enabled without gui";
        }
      ];

      fonts.packages = with stable; []
        ++ (lib.optionals extraTUIWithGUI [
          nerd-fonts.fira-code # proper font for terminal
        ]);
  
      environment.systemPackages = with stable; []
        ## gui stuff ##
        ++ (lib.optionals extraGUI [
          gparted # partitioning
          vlc # proper video player
          varia # downloader + torrent
          easyeffects # mostly cause of volume normalization
          hardinfo2 # system information
          qalculate-qt # calculator
          audacious # music player
        ])

        ## terminal stuff when gui is present ##
        ++ (lib.optionals extraTUIWithGUI [
          kitty # proper terminal
        ])

        ## terminal stuff ##
        ++ (lib.optionals extraTUI [
          lsd
          starship

          unstable.helix # proper editor

          python3
          libqalculate # qalc cli
          yt-dlp # youtube downloader

          nushell # the best shell
          buildah

          shellcheck
        ]);

      # NOTE: localsend needs ports open so use this syntax
      # sharing files, links etc more secure variant of kdeconnect
      programs.localsend.enable = lib.mkDefault extraGUI;
    };
}
