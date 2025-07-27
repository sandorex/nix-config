{ flake, config, pkgs, ... }:

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
    apps = {
      gui.enable = true;
      editor.enable = true;
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
