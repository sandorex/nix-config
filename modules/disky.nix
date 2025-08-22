{ config, lib, pkgs, ... }:

let
  # inherit (builtins) map mapAttrs attrNames attrValues concatStringsSep;

  formatCmd = fs: {
    ext4 = "mkfs.ext4";
    vfat = "mkfs.vfat -F 32"; # TODO idk if this is correct
  }.${fs};

  # TODO use executables from pkgs for sfdisk etc
  # TODO if there is nothing configured just write 'no disks configured' and exit do not write any code
  script = pkgs.writeShellScriptBin "disky" ''
    set -eo pipefail

    DISKS=(${
      # write all the disks so they can be checked
      lib.pipe config.disky [
        builtins.attrNames

        # quote the path just in case
        (builtins.map (x: "\"${x}\""))

        (builtins.concatStringsSep " ")
      ]
    })

    if [[ "''${#DISKS[@]}" -eq 0 ]]; then
        echo "No disks configured for host"
        exit 0
    fi

    not_found=()
    for i in "''${DISKS[@]}"; do
        if [[ ! -e "$i" ]]; then
            not_found+=("$i")
        fi
    done

    if [[ "''${#not_found[@]}" -ne 0 ]]; then
        echo "Following disks were not found, quitting.."
        for i in "''${not_found[@]}"; do
            echo "  $i"
        done
        exit 1
    fi

    echo
    echo "Are you sure you want to delete everything on ''${#DISKS[@]} disk(s) ?"
    echo
    echo "If you are type 'NUKE IT'"
    echo
    read -p "> " ans
    case "$ans" in
      'NUKE IT')
          ;;
      *)
          echo "Cancelled"
          exit 1
          ;;
    esac

    ${
      # apply the sfdisk partition layout before formatting
      lib.pipe config.disky [
        (builtins.mapAttrs (k: v: ''
          sudo sfdisk ${k} <<EOF
          ${v.sfdisk}
          EOF

          ${
            # format all filesystems defined within
            lib.pipe v.fs [
              # bind mounts should be ignored in this case
              (lib.filterAttrs (k: v: v.fsType != "none"))

              (builtins.mapAttrs (k: v: "sudo ${ formatCmd v.fsType } ${v.device}"))

              builtins.attrValues

              (builtins.concatStringsSep "\n")
            ]
          }
        ''))

        builtins.attrValues

        (builtins.concatStringsSep "\n")
      ]
    }
  '';
in
{
  options = {
    disky = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule {
        options = {
          fs = lib.mkOption {
            type = attrs;
            description = ''
              Passed verbatim to `fileSystems`

              Used for error checking etc:
                - Checked if UUIDs defined are in the dump so its truly declarative
                - The `fsType` is used to format the partition properly
            '';
          };

          sfdisk = lib.mkOption {
            type = str;
            description = "Partition dump using sfdisk";
          };
        };
      });
    };

    # TODO this may not be the way to do it but it kinda works as its easy to access the config
    diskyScript = lib.mkOption {
      # default = null;
      default = script;
      description = "The disky install script, run it to format the partitions automatically (dangerous)";
      readOnly = true;
    };
  };

  config = {
    # TODO check if drive are accessed using /dev/disk/by-id/

    # merge all `disky.*.fs` into one
    fileSystems =  lib.mkMerge (builtins.attrValues (builtins.mapAttrs (k: v: v.fs) config.disky));
  };
}
