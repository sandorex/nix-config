{ config, ... }:

{
  # TOSHIBA NVME SSD
  disky."/dev/disk/by-id/nvme-eui.00080d02000a64f3" = {
    fileSystems."/" ={
      device = "/dev/disk/by-partuuid/5e525e2c-5c34-4bcc-bd4b-0ca7e580ba0f";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partuuid/59214e96-a50e-4e56-bf84-68682833e6eb";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    sfdisk = ''
      label: gpt
      label-id: 6908A809-71BF-4F76-A83B-579ECF44AE8C
      device: /dev/disk/by-id/nvme-eui.00080d02000a64f3
      unit: sectors
      first-lba: 2048
      last-lba: 1000215182
      sector-size: 512

      /dev/disk/by-id/nvme-eui.00080d02000a64f3-part1 : start=        4096, size=     2097152, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=59214E96-A50E-4E56-BF84-68682833E6EB, name="EFI"
      /dev/disk/by-id/nvme-eui.00080d02000a64f3-part2 : start=     2101248, size=   998105586, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=5E525E2C-5C34-4BCC-BD4B-0CA7E580BA0F, name="root"
    '';
  };

  # slow hdd WD BLACK CAVIAR
  disky."/dev/disk/by-id/wwn-0x50014ee25ffa742d" = {
    # mount slow hdd
    fileSystems."/mnt/slowmf" = {
      device = "/dev/disk/by-partuuid/55add596-2965-464a-9bb4-386acc173ba5";
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

    sfdisk = ''
      label: gpt
      label-id: F1BBE678-2940-4470-ACB5-F7EAB5087196
      device: /dev/disk/by-id/wwn-0x50014ee25ffa742d
      unit: sectors
      first-lba: 34
      last-lba: 976773134
      sector-size: 512

      /dev/disk/by-id/wwn-0x50014ee25ffa742d-part1 : start=        2048, size=   901273600,type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=55ADD596-2965-464A-9BB4-386ACC173BA5
      /dev/disk/by-id/wwn-0x50014ee25ffa742d-part4 : start=   901275648, size=    75497472,type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F, uuid=BCBBB526-6690-5544-93D8-E231385C1C38
    '';
  };

  # TODO add swapfile
  swapDevices = [ ];
}
