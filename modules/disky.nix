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
          fileSystems = lib.mkOption {
            type = attrs;
            description = "Passed verbatim to `fileSystems`, used for error checking and `fsType` is used to format the partition with correct fs";
          };

          sfdisk = lib.mkOption {
            type = str;
            description = "Partition dump using sfdisk";
          };
        };
      });

      example = {
        "/dev/disk/by-id/wwn-0x353x2d2d2f3f13f2" = {
          fileSystems = {
            "/mnt/slowmf" = {
              device = "/dev/disk/by-partuuid/5046099b-f7f8-4fab-9e76-d295687bb2a8";
              fsType = "ext4";
              options = [
                "defaults"
                "noatime"
                "nodiratime"
                "nofail"
              ];
            };
          };

          sfdisk = ''
            label: gpt
            label-id: F1BBE678-2940-4470-ACB5-F7EAB5087196
            device: /dev/sda
            unit: sectors
            first-lba: 34
            last-lba: 976773134
            sector-size: 512

            /dev/sda1 : start=        2048, size=   901273600, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=5046099B-F7F8-4FAB-9E76-D295687BB2A8
          '';
        };
      };
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
        # basically filterMap for each fs in disky
        eachFs = filterMap: lib.pipe config.disky [
          (lib.mapAttrs (k: v: lib.pipe v.fileSystems [
            # map it into known attrs type
            (lib.mapAttrs (k2: v2: {
              parentName = k;
              fsName = k2;
              fs = v2;
            }))

            # get only the values
            builtins.attrValues

            # filter using custom filter
            (builtins.map filterMap)
          ]))

          builtins.attrValues

          lib.flatten

          # filter null values
          (builtins.filter (x: x != null))
        ];

        # only /dev/disk/by-id/ should be used when referring to drives in disky
        # https://wiki.archlinux.org/title/Persistent_block_device_naming#World_Wide_Name
        badDrivePath = lib.pipe config.disky [
          builtins.attrNames
          (builtins.filter (x: !lib.hasPrefix "/dev/disk/by-id/" x))
          (builtins.map (x: "Disky drive '${x}' does not use '/dev/disk/by-id/' path"))
        ];

        badFsPath = eachFs (x:
          if x.fs.fsType != "none" && !(lib.hasPrefix "/dev/disk/by-partuuid/" x.fs.device) then
            "fileSystem.\"${x.fsName}\".device (${x.fs.fsType}) does not use PARTUUID (disky.\"${x.parentName}\")"
          else
            null
        );

        deskyUUIDs = lib.mapAttrs (k: v:
          lib.pipe v.sfdisk [
            # split by lines
            (builtins.split "\n")

            # filter empty lines
            (builtins.filter (x: x != []))

            # match partition UUIDs using regex
            (builtins.map (x: builtins.match ".*uuid=([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}).*" (lib.toLower x)))

            # filter lines without matches
            (builtins.filter (x: x != null))

            # get the first group (there is only one)
            (builtins.map (x: builtins.elemAt x 0))
          ]
        ) config.disky;

        # check if each non-bind filesystem that uses PARTUUID is in sfdisk dump
        badUUID = eachFs (x:
          let
            uuid = builtins.elemAt (builtins.match ".*([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}).*" (lib.toLower x.fs.device)) 0;
          in
          if lib.hasPrefix "/dev/disk/by-partuuid/" x.fs.device && !(builtins.elem uuid deskyUUIDs.${x.parentName}) then
            "UUID '${uuid}' is not in sfdisk dump (disky.\"${x.parentName}\".fileSystems.\"${x.fsName}\")"
          else
            null
        );
      in []
      ++ badDrivePath
      ++ badFsPath
      ++ badUUID;

    # merge all `disky.*.fs` into one
    fileSystems = lib.mkMerge (builtins.attrValues (builtins.mapAttrs (k: v: v.fileSystems) config.disky));
  };
}
