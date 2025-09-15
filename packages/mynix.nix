{ pkgs
, localPath ? null
, cfgHostname ? null
, thresholdDays ? 5
, ...
}:

pkgs.writeShellScriptBin "mynix" ''
  set -eo pipefail

  ${ if localPath != null then "cd \"${localPath}\"" else ""}

  host="${ if cfgHostname != null then cfgHostname else "$HOSTNAME" }"

  function get_spec() {
      # basically get all specialisation attributes for specified host
      nix eval --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' ".#nixosConfigurations.''${1:?}.config.specialisation" --raw 2>/dev/null
  }

  case "$1" in
      run)
          name="$2"
          shift 2
          nix run ".#packages.x86_64-linux.$name" "$@"
          ;;
      repl)
          nix repl --expr "builtins.getFlake \"$PWD\""
          ;;
      update)
          nix flake update
          ;;
      up-to-date)
          diff="$(( $(date +'%s') - $(git log -1 --pretty="format:%ct" flake.lock) ))"

          # print human readable time
          T="$diff"
          D=$((T/60/60/24))
          H=$((T/60/60%24))
          M=$((T/60%60))
          (( D > 0 )) && printf '%d days ' $D
          (( H > 0 )) && printf '%d hours ' $H
          (( M > 0 )) && printf '%d minutes ' $M
          echo

          # exit with 1 when not up to date
          if [[ "$diff" -gt "$(( ${ toString thresholdDays } * 86400 ))" ]]; then
              exit 1
          else
              exit 0
          fi
          ;;
      check)
          nix flake check
          ;;
      spec)
          shift
          host="''${1:-$host}"

          echo "Getting specialisations for host '$host'"
          spec=($(get_spec $host))
          echo "''${spec[*]}"
          ;;

      # nixos-rebuild
      list)
          nixos-rebuild list-generations
          ;;
      switch|test|build-vm)
          cmd="$1"
          shift

          # ask for specialisation if there are any defined to prevent freezes
          # caused by erasing running desktop environment
          spec=($(get_spec $host))
          arg=""
          if [[ "''${#spec[@]}" -ne 0 ]]; then
              echo "Specialisations: ''${spec[*]}"
              read -p "Selected (enter for none): " ans

              if [[ -n "$ans" ]]; then
                arg="--specialisation $ans"
              fi
          fi

          if [[ "$cmd" == "build-vm" ]]; then
              nixos-rebuild build-vm --flake . $arg "$@"
          else
              sudo nixos-rebuild "$cmd" --flake . $arg "$@"
          fi
          ;;
      boot)
          shift
          sudo nixos-rebuild boot --flake . "$@"
          ;;
      ''')
          cat <<EOF
  Usage: $0 <command>

  Just a wrapper to run with proper path to flake without specifying it each time

  Commands:
      run           - nix run using the flake
      repl          - start repl using flake
      update        - update the flake (does not rebuild)
      up-to-date    - checks for updates and prints how long ago
                      was last update
      check         - checks flake for errors

      # these are basically passed raw to nixos-rebuild
      list
      switch
      test
      boot
      build-vm

  EOF
          ;;
      *)
          echo "Invalid command '$1'"
          exit 1
          ;;
  esac
''
