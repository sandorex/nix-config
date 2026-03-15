{ config, lib, flake, my, pkgs, ... }:

let
  inherit (builtins) filter attrNames attrValues readDir readFile map mapAttrs concatStringsSep;
  inherit (lib) filterAttrs;

  enabled = config.my.flatpak.enable;
  flatpaks = config.my.flatpak.install;
  overrides = config.my.flatpak.overrides;

  flathubRemote = "flathub";
  serviceName = "mynix-flatpak";

  rulesDir = "config/flatpak";
  flakeRulesDir = "${flake}/${rulesDir}";

  getRules = path: lib.pipe path [
    readDir

    # allow only files
    (filterAttrs (k: v: v == "regular"))

    # get only file names
    attrNames

    # filter only conf files
    (filter (name: !(builtins.elem name [ "apply.sh" "README.md" ])))

    # read the file and convert into attrs
    (map (x: { name = x; value = "${config.my.localPath}/${rulesDir}${ lib.strings.removePrefix flakeRulesDir path}/${x}"; }))

    # convert to single attrs
    builtins.listToAttrs
  ];

  flakeHostRulesDir = "${flakeRulesDir}/${my.hostname}";

  # NOTE this makes host rules have priority
  ruleAttrs = lib.pipe ((getRules flakeRulesDir) // (if builtins.pathExists flakeHostRulesDir then (getRules flakeHostRulesDir) else {})) [
    # convert to attrs
    (mapAttrs (k: v: {
      name = k;
      path = v;
    }))
  ];
in
{
  options.my.flatpak = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable flatpak support";
    };

    install = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "Automatically install flatpak apps using a systemd service";
    };

    overrides = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "Flatpak permission overrides";
    };
  };

  config = lib.mkIf enabled {
    # enable flatpak
    services.flatpak.enable = true;
    system.userActivationScripts = {
      # adds flathub source for users
      flatpakSetup = {
        text = ''
          ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists ${flathubRemote} https://flathub.org/repo/flathub.flatpakrepo
        ''
        # if there are flatpaks to install run the service to not slow down activation script
        + lib.optionalString (flatpaks != []) ''
          ${pkgs.systemd}/bin/systemctl --user start "${serviceName}"
        '';
        deps = [];
      };
    };

    # service to only install flatpaks, no updates, no removal
    systemd.user.services.${serviceName} = lib.mkIf (flatpaks != []) {
      script = ''
        installed="$(${pkgs.flatpak}/bin/flatpak list --app --columns=application)"
        to_install="${builtins.concatStringsSep " " flatpaks}"

        # filter already installed
        apps_to_install=()
        for id in $to_install; do
          if [[ "$installed" =~ *"$id"* ]]; then
            continue
          fi

          apps_to_install+=( "$id" )
        done

        # do not try to install if everything is already installed
        if [[ "''${#apps_to_install[@]}" -gt 0 ]]; then
          # make sure there is network as flatpak install always fails without network
          ${pkgs.networkmanager}/bin/nm-online -q --timeout=60

          ${pkgs.flatpak}/bin/flatpak install --user -y --noninteractive ${flathubRemote} "''${apps_to_install[@]}"
        fi
      '';

      # the service should not keep running
      serviceConfig.Type = "oneshot";

      # do not auto start
      wantedBy = [ ];
      after = [ "multi-user.target" ];
    };

    # link the override files if they dont exist
    systemd.user.tmpfiles.users.${config.my.user}.rules = lib.pipe overrides [
      # access ruleAttrs using the name
      (map (x: ruleAttrs.${x} or (throw "Invalid flatpak override '${x}'")))

      # convert into tmpfiles syntax
      # NOTE does not clobber
      (map (x: "L$ %h/.local/share/flatpak/overrides/${x.name} - - - - ${x.path}"))
    ];
  };
}

