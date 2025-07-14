{ config, lib, pkgs, ... }:

let
  enabled = config.my.flatpak.enable;
  flatpaks = config.my.flatpak.install;

  flathubRemote = "flathub";
  serviceName = "mynix-flatpak";
in
{
  options = {
    my.flatpak.enable = lib.mkOption {
      default = config.my.gui; # enable by default if using gui
      type = lib.types.bool;
      description = "Enable flatpak support";
    };

    my.flatpak.install = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "Automatically install flatpak apps using a systemd service";
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
      serviceConfig = {
        # the service should not keep running
        Type = "oneshot";
      };
      # do not auto start
      wantedBy = [ ];
      after = [ "multi-user.target" ];
    };
  };
}

