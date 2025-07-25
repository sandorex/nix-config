{ pkgs
, localPath ? null
, hostname ? null
, ...
}:

pkgs.writeShellScriptBin "mynix" ''
  set -eo pipefail

  ${ if localPath != null then "cd \"${localPath}\"" else ""}

  case "$1" in
      run)
          shift
          nix run ".#$1" "$@"
          ;;
      repl)
          nix repl --expr "builtins.getFlake \"$PWD\""
          ;;
      update)
          nix flake update
          ;;
      up-to-date)
          # after how many days to consider updating
          days=5

          diff="$(( $(date +'%s') - $(stat -c %Y flake.lock) ))"

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
          if [[ "$diff" -gt "$(( days * 86400 ))" ]]; then
              exit 1
          else
              exit 0
          fi
          ;;
      check)
          nix flake check
          ;;

      # nixos-rebuild
      list)
          nixos-rebuild list-generations
          ;;
      switch|test)
          cmd="$1"
          shift

          # ask for specialisations if there are any defined
          arg=""
          if grep -ERq 'specialisation.\w+.configuration' "./hosts/${ if hostname != null then hostname else "$HOSTNAME"}"; then
            read -p "Specialisation (enter for none): " ans

            if [[ -n "$ans" ]]; then
              arg="--specialisation $ans"
            fi
          fi

          sudo nixos-rebuild "$cmd" --flake . $arg "$@"
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

  EOF
          ;;
      *)
          echo "Invalid command '$1'"
          exit 1
          ;;
  esac
''
