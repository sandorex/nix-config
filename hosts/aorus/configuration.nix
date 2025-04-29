{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # public github key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFW11mEmr/RJGDv+VTuOyYqiJhZSvFTYxMkt9un5WiJk sandorex@thorium"
    ];
  };

  #environment.systemPackages = with pkgs; [];

  services.sshd.autostart = true;
}
