{ config, flake, stable, ... }:

{
  imports = [
    ./configuration.nix
    ./apps.nix

    "${flake}/modules"
  ];

  my = {
    user = "sandorex";

    libvirtd.enable = true;
    podman.enable = true;
    bluetooth.enable = true;
    gaming.enable = true;
    apps.terminal = true;

    kde.enable = true;
    hyprland.enable = true;
    tuigreet = {
      enable = true;
      autologin.command = "startplasma-wayland";
    };
  };

  users.users.${config.my.user} = {
    isNormalUser = true;
    description = "${config.my.user}";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # use zsh by default
  users.defaultUserShell = stable.zsh;
  programs.zsh.enable = true;
}
