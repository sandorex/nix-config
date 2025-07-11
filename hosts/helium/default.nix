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

    kde.enable = true;
    sddm.enable = true;
  };

  environment.systemPackages = with stable; [
    emacs
    librewolf
  ];

  programs.firefox.enable = true;

  dotfiles = {
    bin.enable = true;
    bash.enable = true;
    helix.enable = true;
    nano.enable = true;
    kitty.enable = true;
    lsd.enable = true;
  };
}
