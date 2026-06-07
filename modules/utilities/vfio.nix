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
        serviceConfig.Type = "oneshot";
        unitConfig.DefaultDependencies = "no";

        enableStrictShellChecks = true;
        script = ''
          GROUPS=(${ builtins.concatStringsSep " " (map toString byGroup) })
          PATHS=(${ builtins.concatStringsSep " " byPath })

          for group in "''${GROUPS[@]}"; do
            for device in "/sys/kernel/iommu_groups/$group/devices"/*; do
              PATHS+=("$device")
            done
          done

          for path in "''${PATHS[@]}"; do
            name="$(basename "$device")"
            echo "Unbinding driver $name"
            echo "$name" > "$path/driver/unbind"

            echo "Binding $device to vfio-pci"
            echo "$name" > "/sys/bus/pci/drivers/vfio-pci/bind"
          done

          ${pkgs.kmod}/bin/modprobe -i vfio-pci
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
