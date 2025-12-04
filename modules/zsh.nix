{ config, lib, pkgs, ... }:

# basically setups ddcutil to work properly
let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable ddcutil for ext. monitor brightness control";
    };

    isDefault = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Make Z shell the default for all users (including root)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.syntaxHighlighting.enable = true;

    # all users use zsh by default if requested
    users.defaultUserShell = lib.mkIf cfg.isDefault pkgs.zsh;

    # set for main user if not default
    users.users.${config.my.user}.shell = lib.mkIf (!cfg.isDefault) pkgs.zsh;

    dotfiles.enabled = with config.dotfiles.configs; [
      zsh
    ];
  };
}
