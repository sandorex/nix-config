{ repo ? null
, localPath ? ("~/" + repo.localName)
, thresholdDays ? 5
, writeShellApplication
, lib
, pkgs
, ...
}:

let
  mn_run = writeShellApplication {
    name = "mn-run";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      name="$1"
      shift
      nix run "${localPath}#$name" "$@"
    '';
  };

  mn_shell = writeShellApplication {
    name = "mn-shell";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      name="$1"
      shift
      exec nix develop "${localPath}#$name" "$@"
    '';
  };

  mn_repl = writeShellApplication {
    name = "mn-repl";
    runtimeInputs = with pkgs; [ nix ];

    # NOTE: im assigning the flake to `flake` cause its easier to use
    # as you don't need to know what is defined in the repl itself
    text = ''
      nix repl --expr "{ flake = builtins.getFlake \"${localPath}\"; }"
    '';
  };

  mn_update = writeShellApplication {
    name = "mn-update";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      nix flake update --commit-lock-file "$@"
    '';
  };

  mn_last_update = writeShellApplication {
    name = "mn-last-update";
    runtimeInputs = with pkgs; [ nix jq ];

    text = ''
      cd "${localPath}"
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
  };

  mn_check = writeShellApplication {
    name = "mn-check";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      nix flake check "$@"
    '';
  };

  mn_list = writeShellApplication {
    name = "mn-list";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      nixos-rebuild list-generations
    '';
  };

  mn_boot = writeShellApplication {
    name = "mn-boot";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      sudo nixos-rebuild boot --flake . "$@"
    '';
  };

  mn_switch = writeShellApplication {
    name = "mn-switch";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      sudo nixos-rebuild switch --flake .  "$@"
    '';
  };

  mn_test = writeShellApplication {
    name = "mn-test";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      sudo nixos-rebuild test --flake . "$@"
    '';
  };

  mn_build_vm = writeShellApplication {
    name = "mn-build-vm";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      cd "${localPath}"
      nixos-rebuild build-vm --flake . "$@"
    '';
  };

  mn_template = writeShellApplication {
    name = "mn-template";
    runtimeInputs = with pkgs; [ nix ];

    text = ''
      if [[ -z "$1" ]]; then
        echo "No template name was provided"
        exit 1
      fi

      nix flake init -t "${localPath}#$1"
    '';
  };

  # stolen from @vimjoyer discord
  mn_pkgs = writeShellApplication {
    name = "mn-pkgs";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
  };

  mn_opts = writeShellApplication {
    name = "mn-opts";
    runtimeInputs = with pkgs; [
      fzf
      manix
    ];
    text = ''
      manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix '{}'" | xargs manix
    '';
  };

  mn_help = ''
    Usage: $0 <command>

    Just a wrapper to run with proper path to flake without specifying it each time

    Commands:
      run           - nix run using the flake
      shell         - nix develop using the flake
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
in
writeShellApplication {
  name = "mn";

  # all the other scripts are ran from this script
  text = ''
    case "''${1:-}" in
        run)
            shift
            exec ${lib.getExe mn_run} "$@"
            ;;
        shell)
            shift
            exec ${lib.getExe mn_shell} "$@"
            ;;
        repl)
            shift
            exec ${lib.getExe mn_repl} "$@"
            ;;
        update)
            shift
            exec ${lib.getExe mn_update} "$@"
            ;;
        last-update)
            shift
            exec ${lib.getExe mn_last_update} "$@"
            ;;
        check)
            shift
            exec ${lib.getExe mn_check} "$@"
            ;;
        list)
            shift
            exec ${lib.getExe mn_list} "$@"
            ;;
        switch)
            shift
            exec ${lib.getExe mn_switch} "$@"
            ;;
        test)
            shift
            exec ${lib.getExe mn_test} "$@"
            ;;
        build-vm)
            shift
            exec ${lib.getExe mn_build_vm} "$@"
            ;;
        boot)
            shift
            exec ${lib.getExe mn_boot} "$@"
            ;;
        template)
            shift
            exec ${lib.getExe mn_template} "$@"
            ;;
        nixpkgs|pkgs)
            shift
            exec ${lib.getExe mn_pkgs} "$@"
            ;;
        nixopts|opts)
            shift
            exec ${lib.getExe mn_opts} "$@"
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
}
