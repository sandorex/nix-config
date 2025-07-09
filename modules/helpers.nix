{ config, lib, stable, ... }:

# defines helper functions for managing nixos
{
  options = {
    my.helpers.enable = lib.mkEnableOption "helpers";
  };

  config = lib.mkIf config.my.helpers.enable {
    environment.systemPackages = [
      (stable.writeShellScriptBin "mynix" ''
        cd ${config.dotfiles.path}

        case "$1" in
            repl)
                nix repl --expr "builtins.getFlake \"$PWD\""
                ;;
            *) # just redirect to nixos-rebuild
                sudo nixos-rebuild --flake . "$@"
                ;;
        esac
      '')
    ];
  };
}
