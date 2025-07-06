{ config, lib, stable, ... }:

{
  options = {
    my.libvirtd.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable libvirtd virtualization";
    };

    my.podman.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable podman containers";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.my.libvirtd.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;

      # allow user to use libvirtd without sudo
      users.groups.libvirtd.members = [ config.my.user ];
    })

    (lib.mkIf config.my.podman.enable {
      # sets up containers properly so podman works
      virtualisation.containers.enable = true;
      virtualisation.podman.enable = true;

      environment.systemPackages = with stable; [
        distrobox
        # fuse-overlayfs is much faster than the alternative
        # https://github.com/containers/podman/issues/16541
        fuse-overlayfs # podman
      ];
    })
  ];
}
