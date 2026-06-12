{ lib, config, pkgs, ... }:

# enable PCI passthrough easily

let
  enable = config.my.vfio.enable;
  byPath = config.my.vfio.byPath;
  byGroup = config.my.vfio.byGroup;

  lgEnable = config.my.vfio.lookingGlass.enable;
  lgSize = config.my.vfio.lookingGlass.size;
in
{
  options.my.vfio = {
    enable = lib.mkEnableOption "Enable pci passthrough (wont do anything if no devices are set)";

    byPath = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "Pass each device by its literal path";
      example = [ "/sys/devices/pci0000:00/0000:00:08.1/0000:0d:00.0/" ];
    };

    byGroup = lib.mkOption {
      default = [];
      type = with lib.types; listOf int;
      description = "Pass whole IOMMU groups";
      example = [ 16 17 ];
    };

    lookingGlass = {
      enable = lib.mkEnableOption "Enable looking glass client";
      size = lib.mkOption {
        default = 32; # 1080p SDR
        type = with lib.types; int;
        description = "Size to reserve for framebuffer in megabytes (32 for 1080p SDR)";
      };
    };
  };

  config = lib.mkIf enable (lib.mkMerge [
    {
      # vfio stuff has to be before other drivers
      boot.initrd.kernelModules = lib.mkBefore [
        # VFIO passthrough
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

      boot.kernelParams = [
        # TODO this is AMD only
        "amd_iommu=on"

        # NOTE information online is spotty but seems to reduce overhead for host devices
        "iommu=pt"
      ];

      # NOTE this was originally preDeviceCommands in NixOS 25.11
      # manually override the driver as i cannot set order in which kernel modules load
      systemd.services.vfio = {
        description = "Force vfio for devices";
        wantedBy = [ "sysinit.target" ];
        after = [ "systemd-modules-load.service" ];
        before = [ "systemd-udevd.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes"; # without this it will run twice
        };

        unitConfig.DefaultDependencies = "no";

        enableStrictShellChecks = true;
        script = ''
          IOMMU_GROUPS=(${ builtins.concatStringsSep " " (map toString byGroup) })
          PATHS=(${ builtins.concatStringsSep " " byPath })

          for group in "''${IOMMU_GROUPS[@]}"; do
            for device in /sys/kernel/iommu_groups/"$group"/devices/*; do
              if [[ -e "$device" ]]; then
                PATHS+=("$device")
              fi
            done
          done

          # load vfio module before binding it
          ${pkgs.kmod}/bin/modprobe -i vfio-pci

          for path in "''${PATHS[@]}"; do
            if [[ ! -e "$path" ]]; then
              echo "Device $path does not exist"
              continue
            fi

            id="$(basename "$path")"

            # do not replace the driver twice
            if [[ "$(basename "$(readlink "$path/driver")")" == "vfio-pci" ]]; then
              echo "$id is already using vfio-pci"
              continue
            fi

            echo "Forcing vfio-pci driver for $path"

            # unbind old driver (if any)
            [[ -e "$path/driver/unbind" ]] && echo "$id" > "$path/driver/unbind"

            # allow vfio-pci to bind to this driver
            echo "vfio-pci" > "$path/driver_override"

            # bind new driver (does not work without driver_override!)
            echo "$id" > "/sys/bus/pci/drivers/vfio-pci/bind"
          done
        '';
      };
    }

    # looking glass windows "monitor" thingy
    (lib.mkIf lgEnable {
      boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
      boot.extraModprobeConfig = "options kvmfr static_size_mb=${lgSize}";

      environment.systemPackages = with pkgs; [ looking-glass-client ];
    })
  ]);
}
