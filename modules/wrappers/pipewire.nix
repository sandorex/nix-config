{ config, lib, ... }:

{
  options = {
    my.pipewire.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use pipewire";
    };
  };

  config = lib.mkIf config.my.pipewire.enable {
    # audio stuff (use pipewire not pulseaudio)
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
