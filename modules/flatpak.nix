{ pkgs, ... }:

{
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
}

