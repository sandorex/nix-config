{ config, lib, ... }:

let
  opts = config.my.hardware;
in
{
  options.my.hardware = {
    rdna3 = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule {
        options = {
          fan-curve = lib.mkOption {
            default = null;
            type = with lib.types; nullOr (listOf str);
            description = "Set custom fan curve for RDNA3 gpus";
            example = [
              "0 40 33"
              "1 50 35"
              "2 60 50"
              "3 70 75"
              "4 85 99"
            ];
          };

          zero-rpm = lib.mkOption {
            default = null;
            type = with lib.types; nullOr bool;
            description = "Enable/disable zero-rpm";
          };
        };
      });

      example = {
        # use absolute gpu path (RECOMMENDED)
        "/sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/0000:02:00.0/0000:03:00.0/" = {
          zero-rpm = false;
        };

        # use relative gpu path
        "/sys/class/drm/card1/device/" = {
          zero-rpm = false;
        };
      };
    };
  };

  config = lib.mkIf (config.my.hardware.rdna3 != {}) {
    # TODO write assertion for exact number of elements in fan curve
    assertions = [
      {
        assertion = config.boot.kernelPackages.kernelAtLeast "6.13";
        message = "Kernel 6.13 is required for RDNA3 zero-rpm toggle";
      }
    ];

    # enable overclocking and fan control
    hardware.amdgpu.overdrive.enable = true;

    # NOTE do not apply multiple times in quick succession or the value
    # will SHOW as applied but will not actually take effect
    systemd.services.mynix-rdna3 = lib.mkIf config.hardware.amdgpu.overdrive.enable {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      enableStrictShellChecks = true;
      script =
      let
        # writes all values into the path in format `write <value> >> <path>`
        writeAll = path: values: (builtins.concatStringsSep "\n" (map (x: "echo \"${x}\" >> \"${path}\"") values));

        # path to the sysfs
        fan_zero_rpm_enable = "/gpu_od/fan_ctrl/fan_zero_rpm_enable";
        fan_curve = "/gpu_od/fan_ctrl/fan_curve";
      in
      ''
        # shellcheck disable=SC2129

        ${
          lib.pipe config.my.hardware.rdna3 [
            (builtins.mapAttrs (k: v: ''
              if [[ -e "${k}" ]]; then
              ${
                if v.zero-rpm != null then
                  writeAll (k + fan_zero_rpm_enable) [
                    (if v.zero-rpm == true then "1" else "0")
                  ]
                else
                  "# zero-rpm"
              }

              ${
                if v.fan-curve != null then
                  writeAll (k + fan_curve) (v.fan-curve)
                else
                  "# fan-curve"
              }

              # apply only once for both
              ${ writeAll (k + fan_curve) [ "c" ] }
              fi
            ''))

            builtins.attrValues

            (builtins.concatStringsSep "\n")
          ]
        }
      '';
    };
  };
}

