{ config, lib, stable, hostname, ... }:

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
            update)
                nix flake update
                ;;
            check)
                nix flake check
                ;;
            list)
                nixos-rebuild list-generations
                ;;

            # nixos-rebuild
            switch|test)
                cmd="$1"
                shift

                # ask for specialisations if there are any defined
                if grep -ERq 'specialisation.\w+.configuration' ./hosts/${hostname}; then
                  read -p "Specialisation (enter for none): " ans

                  if [[ -n "$ans" ]]; then
                    arg="--specialisation $ans"
                  fi
                fi

                sudo nixos-rebuild "$cmd" --flake . $arg "$@"
                ;;
            boot)
                sudo nixos-rebuild boot --flake . "$@"
                ;;
            *)
                echo "Invalid command '$1'"
                exit 1
                ;;
        esac
      '')
    ];
  };
}
