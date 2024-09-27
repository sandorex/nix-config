{ lib, stable, unstable, system, ... }:

# TODO remove most of this and move it into modules
{
  imports = [ ./hardware-configuration.nix ];

  # allow nix command and flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # TODO pass this from the flake
  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  i18n.defaultLocale = "en_US.UTF-8";

  # create systemd service for SSH but do not start it automatically
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [];

  # cinnamon desktop using X11
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [];
  };

  programs.firefox.enable = true;

  environment.systemPackages = [
    unstable.neovim
    stable.git
  ];
  
  # do not touch
  system.stateVersion = "24.05";
}
