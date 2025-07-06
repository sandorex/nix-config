{ config, lib, pkgs, ... }:

{
  options = {
    my.flatpak.enable = lib.mkOption {
      default = config.my.gui; # enable by default if using gui
      type = lib.types.bool;
      description = "Enable flatpak support";
    };
  };

  config = lib.mkIf config.my.flatpak.enable {
    # enable flatpak
    services.flatpak.enable = true;
    system.userActivationScripts = {
      # adds flathub source for users
      flatpakSetup = {
        text = ''
          ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
        deps = [];
      };
    };
  };
}

