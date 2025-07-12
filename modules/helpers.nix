{ config, lib, stable, ... }:

# defines helper functions for managing nixos
{
  options = {
    my.helpers.enable = lib.mkEnableOption "helpers";
  };

  config = lib.mkIf config.my.helpers.enable {
    environment.systemPackages = [
      (stable.writeShellScriptBin "mynix" ''
        set -eo pipefail

        cd ${config.my.localPath}

        case "$1" in
            repl)
                nix repl --expr "builtins.getFlake \"$PWD\""
                ;;
            *) # just redirect to nixos-rebuild
                read -p "Enter specialisation (press enter for none): " ans

                arg=""
                if [[ -n "$ans" ]]; then
                    arg="--specialisation $ans"
                fi

                sudo nixos-rebuild $arg --flake . "$@"
                ;;
        esac
      '')
    ];
  };
}
