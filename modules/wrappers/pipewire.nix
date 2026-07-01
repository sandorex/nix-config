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
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;

      extraConfig.pipewire = {
        # fixes crackling sound (games running through proton often have it)
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3190
        # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/3198
        #
        # the latency in audio (quantum / rate * 1000)
        # can also be set in pw-metadata or using `PULSE_LATENCY_MSEC`
        quantum-fix = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [48000];

            # default latency is 16.66ms
            "default.clock.quantum" = 800;       # default 1024

            # minimal latency is 5.33ms
            "default.clock.min-quantum" = 256;   # default 32

            # max latency 21.33ms
            "default.clock.max-quantum" = 1024;  # default 8192
          };
        };

      };
    };

    services.pipewire.wireplumber.extraConfig = {
      # increase suspend timeout
      timeout-increase = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                node.name = "~alsa_output.*";
              }
            ];
            actions = {
              update-props = {
                # suspend after 1 minute
                session.suspend-timeout-seconds = (1 * 60);
              };
            };
          }
        ];
      };
    };
  };
}
