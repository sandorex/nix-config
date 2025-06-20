{ stable, ... }:

{
  # enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
 
  environment.systemPackages = with stable; [
    # for some reason this is needed for bluetooth even when pipewire is used
    pulseaudioFull
  ];

  # NOTE: this prevents use of headset microphones but fixes issues with cheap earbuds
  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
    wireplumber.settings = {
      bluetooth.autoswitch-to-headset-profile = false
    }

    monitor.bluez.properties = {
      bluez5.roles = [ a2dp_sink a2dp_source ]
    }
    '')
  ];
}
