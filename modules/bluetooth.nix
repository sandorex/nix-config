{ stable, ... }:

{
  # enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
 
  environment.systemPackages = with stable; [
    # for some reason this is needed for bluetooth even when pipewire is used
    pulseaudioFull
  ];
}
