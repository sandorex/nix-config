{ pkgs
, flake
, ...
}:

# this is just a wrapper to run diskyScript with current hostname as nixosConfiguration name

pkgs.writeShellScriptBin "disky-runner" ''
  set -eo pipefail

  # accept hostname from input
  if [[ -n "$1" ]]; then
    HOST="$1"
  else
    HOST="$HOSTNAME"
    if [[ -z "$HOST" ]]; then
        HOST="$(hostname)"
    fi
  fi

  ${pkgs.nix}/bin/nix run "${flake}#nixosConfigurations.''${HOST}.config.diskyScript"
''
