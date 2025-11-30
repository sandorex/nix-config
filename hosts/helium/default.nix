{ config, pkgs, ... }:

{
  imports = [
    ../../modules/base/laptop.nix

    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.05";

  users.users.${config.my.user} = {
    isNormalUser = true;
    description = "${config.my.user}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  my = {
    podman.enable = true;
    bluetooth.enable = true;
    flatpak.enable = true;
    apps = {
      base.enable = true;
      standard.enable = true;

      dotfiles.enable = true;
    };

    cinnamon.enable = true;
    lightdm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    emacs
    librewolf
  ];

  my.flatpak.install = [
    "com.stremio.Stremio"
  ];

  programs.firefox.enable = true;
}
