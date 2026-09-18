{ config, ... }:

# NOTE: flatpak or any other container based tech has access to only home, so
# all things should be accessible from ~/ path instead of only /mnt/

let
  # TOSHIBA 500GB NVME SSD
  #
  # BTRFS subvolumes:
  #   @root
  #   @root/srv
  #   @root/var/lib/portables
  #   @root/var/lib/machines
  #   @root/tmp
  #   @root/var/tmp
  #
  #   @home
  #   @home/sandorex/.local/share/Steam (compression=none)
  #   @home/sandorex/Downloads
  #   @home/sandorex/.cache
  main = {
    path = "/dev/disk/by-id/nvme-eui.00080d02000a64f3";
    bootPartition = "/dev/disk/by-id/nvme-eui.00080d02000a64f3-part1";
    rootPartition = "/dev/disk/by-id/nvme-eui.00080d02000a64f3-part2";
  };

  # WD BLACK CAVIAR 500GB 7200RPM
  hdd1 = {
    mountPath = "/mnt/hdd1";
    path = "/dev/disk/by-id/wwn-0x50014ee25ffa742d";
    partition = "/dev/disk/by-id/wwn-0x50014ee25ffa742d-part1";
  };

  # WD GREEN 500GB 7200RPM
  hdd2 = {
    mountPath = "/mnt/hdd2";
    path = "/dev/disk/by-id/wwn-0x50014ee25dda123d";
    partition = "/dev/disk/by-id/wwn-0x50014ee25dda123d-part1";
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ## MAIN
  fileSystems."/" = {
    device = main.rootPartition;
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/home" = {
    device = main.rootPartition;
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/boot" = {
    device = main.bootPartition;
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  ## HDD1
  fileSystems.${hdd1.mountPath} = {
    device = hdd1.partition;
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "nodiratime"
      "nofail"
    ];
  };

  fileSystems."/home/${config.my.user}/hdd1" = {
    device = hdd1.mountPath;
    depends = [ hdd1.mountPath ];
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };

  # NOTE moved from ~/ws -> ~/Projects/ws
  fileSystems."/home/${config.my.user}/Projects/ws" = {
    device = "${hdd1.mountPath}/ws";
    depends = [ hdd1.mountPath ];
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };

  ## HDD2
  fileSystems.${hdd2.mountPath} = {
    device = hdd2.partition;
    fsType = "btrfs";
    options = [
      "noatime"
      "nofail"
    ];
  };

  fileSystems."/home/${config.my.user}/hdd2" = {
    device = hdd2.mountPath;
    depends = [ hdd2.mountPath ];
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };

  # TODO add swapfile
  swapDevices = [ ];
}
