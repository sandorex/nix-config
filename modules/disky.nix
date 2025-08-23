{ config, lib, pkgs, ... }:

let
  formatCmd = fs: {
    ext4 = "${pkgs.e2fsprogs}/bin/mkfs.ext4";
    vfat = "${pkgs.dosfstools}/bin/mkfs.vfat"; # TODO should the boot partition be vfat or fat32?
  }.${fs};

  script = pkgs.writeShellScriptBin "disky" ''
    set -eo pipefail

    ${
      # if nothing is configured just quit
      if config.disky == {} then ''
        echo "No disks configured for host"
        exit 1
      '' else ""
    }

    DISKS=(${
      # write all the disks so they can be checked
      lib.pipe config.disky [
        builtins.attrNames

        # quote the path just in case
        (builtins.map (x: "\"${x}\""))

        (builtins.concatStringsSep " ")
      ]
    })

    # do not modify anything if there are any drives missing on the system
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

    # cache the password
    sudo echo -n ""

    ${
      # apply the sfdisk partition layout before formatting
      lib.pipe config.disky [
        (builtins.mapAttrs (k: v: ''
          sudo ${pkgs.util-linux}/bin/sfdisk ${k} <<EOF
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

    # NOTE this is janky but works, and you can easily access it via `nixosConfigurations.*.config.diskyScript`
    diskyScript = lib.mkOption {
      default = script;
      description = "The disky install script derivation, run it to format the partitions automatically (dangerous)";
      readOnly = true;
    };
  };

  config = {
    warnings =
      let
        # only /dev/disk/by-id/ should be used when referring to drives in disky
        # https://wiki.archlinux.org/title/Persistent_block_device_naming#World_Wide_Name
        badDrivePath = lib.pipe config.disky [
          builtins.attrNames
          (builtins.filter (x: !lib.hasPrefix "/dev/disk/by-id/" x))
          (builtins.map (x: "Disky drive '${x}' does not use by-id path"))
        ];

        # fileSystems should be mounted by /dev/disk/by-partuuid/ cause its restored by sfdisk, and uuid
        # is regenerated on formatting and its not recommended to set it explicitly
        badFsPath = lib.pipe config.disky [
          # go over each fs defined
          (lib.mapAttrs (k: v: lib.pipe v.fs [
            # filter fs (fsType of "none" is a bind mount)
            (lib.filterAttrs (k2: v2:
              v2.fsType != "none" && !(lib.hasPrefix "/dev/disk/by-partuuid/" v2.device)
            ))
            (lib.mapAttrs (k2: v2: {
              parentName = k;
              fsName = k2;
              fs = v2;
            }))
            builtins.attrValues
          ]))

          builtins.attrValues

          lib.flatten

          (builtins.map (x: "fileSystem.\"${x.fsName}\".device (${x.fs.fsType}) does not use PARTUUID (disky.\"${x.parentName}\")"))
        ];

        # check if UUIDs used to mount things are the same as in in the dump (using PARTUUID)
        # badUUID = lib.pipe config.disky [
        #   (lib.mapAttrs (k: v: lib.pipe v.fs [
        #     # filter fs (fsType of "none" is a bind mount)
        #     (lib.filterAttrs (k2: v2:
        #       v2.fsType != "none" && (lib.hasPrefix "/dev/disk/by-partuuid/" v2.device)
        #     ))
        #     (lib.mapAttrs (k2: v2: {
        #       parentName = k;
        #       fsName = k2;
        #       fs = v2;
        #       uuid = builtins.elemAt (builtins.match "/dev/disk/by-partuuid/(.+)" v2.device) 0;
        #     }))
        #     builtins.attrValues

        #     # check if uuid is in sfdisk dump
        #     (builtins.filter (x: (lib.match "(${lib.escapeRegex x.uuid})" v.sfdisk) != []))
        #     # (builtins.map (x: x.))
        #     # (lib.filterAttrs (k2: v2: v2.))
        #   ]))

        #   builtins.attrValues

        #   lib.flatten

        #   (builtins.map (x: "fileSystem.\"${x.fsName}\".device ${x.uuid} is not in sfdisk dump"))

        #   (x: lib.traceSeq x x)
        # ];
      in []
      ++ badDrivePath
      ++ badFsPath;

    # merge all `disky.*.fs` into one
    fileSystems = lib.mkMerge (builtins.attrValues (builtins.mapAttrs (k: v: v.fs) config.disky));
  };
}
