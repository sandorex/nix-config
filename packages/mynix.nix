{ repo
, localPath ? ("~/" + repo.localName)
, cfgHostname ? null
, thresholdDays ? 5
, writeShellApplication
, symlinkJoin
, pkgs
, ...
}:

let
  # cd = if localPath != null then "cd \"${localPath}\"" else "";
  # TODO Remove this and jsut write cd ${localPath}
  cd = "cd \"${localPath}\"";

  scripts = [
    (writeShellApplication {
      name = "mn-run";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        name="$1"
        shift
        nix run "${localPath}#$name" "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-repl";
      runtimeInputs = with pkgs; [ nix ];

      # NOTE: im using assigning the flake to the flake cause its easier to use
      # as you don't need to know what is defined in the repl itself
      text = ''
        nix repl --expr "{ flake = builtins.getFlake \"${localPath}\"; }"
      '';
    })

    (writeShellApplication {
      name = "mn-update";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        nix flake update --commit-lock-file "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-last-update";
      runtimeInputs = with pkgs; [ nix jq ];

      text = ''
        ${cd}
        nixpkgs_lastModified="$(nix eval --impure --raw --expr "toString (builtins.getFlake (toString ./.)).inputs.nixpkgs.lastModified")"
        diff="$(( $(date +'%s') - nixpkgs_lastModified ))"

        # print human readable time
        T="$diff"
        D=$((T/60/60/24))
        H=$((T/60/60%24))
        M=$((T/60%60))
        rel_time=""
        (( D > 0 )) && rel_time="$rel_time''${D}d "
        (( H > 0 )) && rel_time="$rel_time''${H}h "
        (( M > 0 )) && rel_time="$rel_time''${M}m "
        printf '%s ago\n' "''${rel_time% }"

        # exit with 1 when not up to date
        if [[ "$diff" -gt "$(( ${ toString thresholdDays } * 86400 ))" ]]; then
            exit 1
        else
            exit 0
        fi
      '';
    })

    (writeShellApplication {
      name = "mn-check";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        nix flake check "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-list";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        nixos-rebuild list-generations
      '';
    })

    (writeShellApplication {
      name = "mn-boot";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        sudo nixos-rebuild boot --flake . "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-switch";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        sudo nixos-rebuild switch --flake .  "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-test";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        sudo nixos-rebuild test --flake . "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-build-vm";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        ${cd}
        nixos-rebuild build-vm --flake . "$@"
      '';
    })

    (writeShellApplication {
      name = "mn-template";
      runtimeInputs = with pkgs; [ nix ];

      text = ''
        if [[ -z "$1" ]]; then
          echo "No template name was provided"
          exit 1
        fi

        nix flake init -t "${localPath}#$1"
      '';
    })

    # stolen from @vimjoyer discord
    (writeShellApplication {
      name = "mn-pkgs";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })

    (writeShellApplication {
      name = "mn-opts";
      runtimeInputs = with pkgs; [
        fzf
        manix
      ];
      text = ''
        manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
      '';
    })
  ];

  mn_help = ''
    Usage: $0 <command>

    Just a wrapper to run with proper path to flake without specifying it each time

    Commands:
      run           - nix run using the flake
      repl          - start repl using flake
      update        - update the flake (does not rebuild)
      last-update   - prints if current generation is out of date, and when
                      was it built
      check         - checks flake for errors
      template      - run 'nix flake init' with my templates
      nixopts|opts  - search options using manix
      nixpkgs|pkgs  - search pkgs using nix-search-tv

      list          - nixos-rebuild --list-generations
      switch        - nixos-rebuild switch
      test          - nixos-rebuild test
      boot          - nixos-rebuild boot
      build-vm      - nixos-rebuild build-vm
  '';

  mn = writeShellApplication {
    name = "mn";
    runtimeInputs = scripts;

    text = ''
      case "''${1:-}" in
          run)
              shift
              mn-run "$@"
              ;;
          repl)
              shift
              mn-repl "$@"
              ;;
          update)
              shift
              mn-update "$@"
              ;;
          last-update)
              shift
              mn-last-update "$@"
              ;;
          check)
              shift
              mn-check "$@"
              ;;
          list)
              shift
              mn-list "$@"
              ;;
          switch)
              shift
              mn-switch "$@"
              ;;
          test)
              shift
              mn-test "$@"
              ;;
          build-vm)
              shift
              mn-build-vm "$@"
              ;;
          boot)
              shift
              mn-boot "$@"
              ;;
          template)
              shift
              mn-template "$@"
              ;;
          nixpkgs|pkgs)
              shift
              mn-pkgs "$@"
              ;;
          nixopts|opts)
              shift
              mn-opts "$@"
              ;;
          ''')
              cat <<EOF
    ${mn_help}
    EOF
              ;;
          *)
              echo "Invalid command '$1'"
              exit 1
              ;;
      esac
    '';
  };
in
# make it a single package
symlinkJoin {
  name = mn.name;
  paths = scripts ++ [ mn ];
}
