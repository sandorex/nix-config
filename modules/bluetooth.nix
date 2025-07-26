{ config, lib, pkgs, ... }:

{
  options = {
    my.bluetooth.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable bluetooth support";
    };
    
    my.bluetooth.disableHeadsetProfile = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Disables headset profile which disables microphone usage but improves reliablility when connecting to cheap earbuds";
    };
  };

  config = lib.mkIf config.my.bluetooth.enable {
    # enable bluetooth
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.bluetooth.settings = {
      Policy = {
        # disable automatic connection
        ReconnectAttempts = 0;
      };
    };
 
    environment.systemPackages = with pkgs; [
      # for some reason this is needed for bluetooth even when pipewire is used
      pulseaudioFull
    ];

    # NOTE: this prevents use of headset microphones but fixes issues with cheap earbuds
    services.pipewire.wireplumber.configPackages = lib.optionals (config.my.bluetooth.disableHeadsetProfile && config.my.pipewire.enable) [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
      wireplumber.settings = {
        bluetooth.autoswitch-to-headset-profile = false
      }

      monitor.bluez.properties = {
        bluez5.roles = [ a2dp_sink a2dp_source ]
      }
      '')
    ];
  };
}
