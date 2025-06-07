{ stable, ... }:

# this module provides all common stuff between all desktops
{
  # audio stuff (use pipewire not pulseaudio)
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
