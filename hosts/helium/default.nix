{ flake, config, stable, ... }:

{
  imports = [
    ./configuration.nix

    "${flake}/modules"
  ];

  users.users.${config.my.user} = {
    isNormalUser = true;
    description = "${config.my.user}";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  my = {
    podman.enable = true;
    bluetooth.enable = true;
    extras = {
      gui.enable = true;
      terminal.enable = true;
    };
    helpers.enable = true;

    cinnamon.enable = true;
    lightdm.enable = true;
  };

  environment.systemPackages = with stable; [
    emacs
    librewolf
  ];

  programs.firefox.enable = true;

  dotfiles.enabled = with config.dotfiles.configs; [
    bin
    bash
    kitty
    helix
    nano
  ];
}
