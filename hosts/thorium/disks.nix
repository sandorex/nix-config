{ config, ... }:

{
  # TOSHIBA NVME SSD
  disky."/dev/disk/by-id/nvme-eui.00080d02000a64f3" = {
    fileSystems."/" ={
      device = "/dev/disk/by-uuid/fa64d2ec-005e-4a2a-a9e2-4fc1cec05ec7";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/9471-17E8";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # TODO add username variable do not hardcode it
  # slow hdd WD BLACK CAVIAR
  disky."/dev/disk/by-id/wwn-0x50014ee25ffa742d" = {
    # mount slow hdd
    fileSystems."/mnt/slowmf" = {
      device = "/dev/disk/by-uuid/5046099b-f7f8-4fab-9e76-d295687bb2a8";
      fsType = "ext4";
      options = [
        "defaults"
        "noatime"
        "nodiratime"
        "nofail"
      ];
    };

    # NOTE: links are fragile, any kind of containerization breaks them so bind mounts instead
    fileSystems."/home/${config.my.user}/slowmf" = {
      device = "/mnt/slowmf";
      depends = [
        "/mnt/slowmf"
      ];
      fsType = "none";
      options = [
        "bind"
        "nofail"
      ];
    };

    fileSystems."/home/${config.my.user}/ws" = {
      device = "/mnt/slowmf/ws";
      depends = [
        "/mnt/slowmf"
      ];
      fsType = "none";
      options = [
        "bind"
        "nofail"
      ];
    };
  };

  # TODO add swapfile
  swapDevices = [ ];
}
