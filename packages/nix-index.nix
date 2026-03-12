{ writeShellApplication
, curl
, nix-index
, ...
}:

# basic wrapper around nix-locate to automatically update index if outdated

let
  update-frequency = 7;
in
writeShellApplication {
  name = "nix-locate";
  runtimeInputs = [ nix-index curl ];

  text = ''
    set -e
    UPDATE=0

    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index

    if [[ ! -f ./files ]]; then
      UPDATE=1
    else
      file_time=$(stat --format='%Y' ./files)
      current_time=$( (date +%s) )
      if (( file_time < ( current_time - ( 60 * 60 * 24 * ${ toString update-frequency } ) ) )); then
        UPDATE=1
      fi
    fi

    if [[ "$UPDATE" -eq 1 ]]; then
      echo "Updating nix-index database.."

      wcurl -o files "https://github.com/nix-community/nix-index-database/releases/latest/download/index-x86_64-linux"
    fi

    nix-locate "$@"
    '';
}
