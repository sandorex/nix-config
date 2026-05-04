{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_18; # RDNA3 fan control req 6.13+

  # enable gpu overclocking and fan control
  hardware.amdgpu.overdrive.enable = true;

  # gpu fan control
  services.lact.enable = true; # fan curve gui

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "drivetemp" ];

  # ryzen igpu
  #  groups 16 17
  #  ids    1002:1638 1002:1637
  my.vfio = {
    enable = true;
    byGroup = [ 16 17 ];
  };

  specialisation.no-passthrough.configuration = {
    # disable passthrough
    my.vfio.enable = lib.mkForce false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
