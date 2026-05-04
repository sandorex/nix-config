{ lib, config, pkgs, ... }:

# enable PCI passthrough easily

let
  enable = config.my.vfio.enable;
  byId = config.my.vfio.byId;
  byPath = config.my.vfio.byPath;
  byGroup = config.my.vfio.byGroup;

  lgEnable = config.my.vfio.lookingGlass.enable;
  lgSize = config.my.vfio.lookingGlass.size;
in
{
  options.my.vfio = {
    enable = lib.mkEnableOption "Enable pci passthrough (wont do anything if no devices are set)";
    byId = lib.mkOption {
      default = [];
      type = with lib.types; listOf str;
      description = "Pass each device by its product and vendor id (not recommended)";
      example = [ "1002:1638" "1002:1637" ];
    };

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
      example = [ "16" "17" ];
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
        "amd_iommu=on"

        # NOTE information online is spotty but seems to reduce overhead for host devices
        "iommu=pt"
      ]
      ++ lib.optionals (byId != []) "vfio-pci.ids=${ lib.concatStringsSep "," byId }";

      # have to manually override the driver as i cannot set order in which kernel
      # modules load
      boot.initrd.preDeviceCommands = ''
        GROUPS="${ builtins.concatStringsSep " " byGroup }"
        PATHS="${ builtins.concatStringsSep " " byPath }"

        for group in $GROUPS; do
          for device in /sys/kernel/iommu_groups/$group/devices/*; do
            echo "vfio-pci" > "$device/driver_override"
          done
        done

        for device in $PATHS; do
          echo "vfio-pci" > "$device/driver_override"
        done

        modprobe -i vfio-pci
      '';
    }

    # looking glass windows "monitor" thingy
    (lib.mkIf lgEnable {
      boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
      boot.extraModprobeConfig = "options kvmfr static_size_mb=${lgSize}";

      environment.systemPackages = with pkgs; [ looking-glass-client ];
    })
  ]);
}
