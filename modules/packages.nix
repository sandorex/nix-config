{ config, lib, stable, unstable, ... }:

# contains all packages (gui and tui)
{
  options = {
    my.apps.extras = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Install extra gui applications";
    };

    my.apps.terminal = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install extra terminal applications";
    };
  };

  config =
    let
      extraGUI = config.my.apps.extras;
      extraTUI = config.my.apps.terminal;
      extraTUIWithGUI = config.my.apps.terminal && config.my.gui;
    in
    {
      assertions = [
        {
          assertion = (config.my.apps.extras && config.my.gui) || !config.my.apps.extras;
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
        ]);

      # NOTE: localsend needs ports open so use this syntax
      # sharing files, links etc more secure variant of kdeconnect
      programs.localsend.enable = lib.mkDefault extraGUI;
    };
}
