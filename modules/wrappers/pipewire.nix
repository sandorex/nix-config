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
        quantum-fix = {
          "context.properties" = {
            "default.clock.quantum" = 1024;      # default 1024
            "default.clock.min-quantum" = 1024;  # default 32
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
