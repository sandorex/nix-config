{ config, lib, ... }:

# this runs garbage collector but always keeps max X number of generations so
# generations are not deleted if they are old but if there are too many

{
  options = {
    my.gc.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable automatic garbage collection while keeping X number of generations regardless of their age";
    };

    my.gc.keep-generations = lib.mkOption {
      default = 10;
      type = lib.types.ints.positive;
      description = "Keep this number of generations from being garbage collected";
    };
  };

  config = lib.mkIf config.my.gc.enable {
    # automatic garbage collection
    # NOTE do not use --delete-older-than as that will delete any generation that is old even if
    # there are very few available so you are loosing rollback ability if you dont update often
    nix.gc = {
      automatic = true;
      dates = "weekly";
    };

    # clean up generations before regular garbage collecting
    systemd.services.nix-gc.wants = [ "nix-gen-gc.service" ];

    # automatic generation garbage collection
    systemd.services.nix-gen-gc = {
      description = "NixOS Generation Garbage Collector";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = builtins.concatStringsSep " " [
          "${config.nix.package.out}/bin/nix-env"

          # very verbose output
          "-vvvv"

          # main system profile
          "--profile /nix/var/nix/profiles/system"

          # delete any generations after 10th
          "--delete-generations +${toString config.my.gc.keep-generations}"
        ];
      };
    };
  };
}
