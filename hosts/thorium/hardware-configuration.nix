{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # RDNA3 zero rpm options are in 6.13+
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  hardware.amdgpu.overdrive.enable = true; # enable overclocking and fan control

  # TODO move to its own module after testing!
  # set GPU options
  systemd.services.gpu-rdna3 = lib.mkIf config.hardware.amdgpu.overdrive.enable {
    enable = false;
    wantedBy = [ "multi-user.target" ];
    enableStrictShellChecks = true;
    script = ''
      # just set it for all supported gpus
      for card in /sys/class/drm/card[0-9]*; do
        zero_rpm_file="$card/device/gpu_od/fan_ctrl/fan_zero_rpm_enable"
        curve_file="$card/device/gpu_od/fan_ctrl/fan_curve"

        if [[ -e "$zero_rpm_file" ]]; then
          echo "Disabling zero-rpm for '$card'"
          echo 0 > "$zero_rpm_file"

          echo "c" > "$zero_rpm_file"
        fi

        if [[ -e "$curve_file" ]]; then
          echo "0 40 33" > "$curve_file"
          echo "1 50 35" > "$curve_file"
          echo "2 60 50" > "$curve_file"
          echo "3 70 75" > "$curve_file"
          echo "4 85 99" > "$curve_file"

          echo "c" > "$curve_file"
        fi
      done
    '';
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd", "drivetemp" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
