{ config, lib, pkgs, ... }:

let
  cfg = config.my.zsh;
in
{
  options.my.zsh = {
    enable = lib.mkEnableOption "Enable Z shell";
    isDefault = lib.mkEnableOption "Make Z shell the default for all users (including root)";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.zsh.syntaxHighlighting.enable = true;

    # all users use zsh by default if requested
    users.defaultUserShell = lib.mkIf cfg.isDefault pkgs.zsh;

    # set for main user if not default
    users.users.${config.my.user}.shell = lib.mkIf (!cfg.isDefault) pkgs.zsh;

    my.dotfiles.enabled = with config.my.dotfiles.configs; [
      zsh
    ];
  };
}
