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
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
