{ pkgs
, flake
, ...
}:

# automated installer
#
# should do following things
# - clone git repository in temp dir
# - format disks with disky
# - mount disks using 'fileSystems.*' information
# - run the installer
# - move the git repository to the home of the user

pkgs.writeShellScriptBin "installer" ''
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

  echo "TODO"
  exit 1
''
