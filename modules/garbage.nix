{ config, lib, ... }:

{
  options = {
    nix.gc.keep-generations = lib.mkOption {
      default = 15;
      type = lib.types.ints.positive;
      description = "Keep this number of generations from being garbage collected";
    };
  };

  config = {
    # automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      # do not delete generations as that is done using nix-gen-gc
      # options = "--delete-older-than 15d";
    };

    # clean up generations before garbage collecting
    systemd.services.nix-gc.wants = [ "nix-gen-gc.service" ];

    # automatic generation garbage collection
    systemd.services.nix-gen-gc = {
      description = "NixOS Generation Garbage Collector";
      script = "exec ${config.nix.package.out}/bin/nix-env -vvvv --profile /nix/var/nix/profiles/system --delete-generations +${toString config.nix.gc.keep-generations}";
      serviceConfig.Type = "oneshot";
    };
  };
}
