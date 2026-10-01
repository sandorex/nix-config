{ config, lib, pkgs, ... }:

{
  options = {
    my.bluetooth.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable bluetooth support";
    };
  };

  config = lib.mkIf config.my.bluetooth.enable {
    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;

    environment.systemPackages = with pkgs; [
      # for some reason this is needed for bluetooth even when pipewire is used
      pulseaudioFull
    ];

    services.pipewire.wireplumber.extraConfig = {
      bluetooth-tweaks = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };

        "monitor.bluez.rules" = [
          {
            matches = [
              {
                "device.name" = "~bluez_card.*";
              }
            ];
            actions = {
              update-props = {
                # do not use headset by default
                "media-role.use-headset-profile" = false;
                "bluez5.autoswitch-profile" = false;
                "bluez5.auto-connect" = [ "a2dp_sink" ];
              };
            };
          }
        ];
      };
    };
  };
}
