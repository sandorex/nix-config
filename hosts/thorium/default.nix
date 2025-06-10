{ flake, stable, ... }:

{
  imports = [
    ./configuration.nix
    ./apps.nix
    ./terminal.nix
    "${flake}/modules/base.nix"
    "${flake}/modules/flatpak.nix"
    "${flake}/modules/printing.nix"
    "${flake}/modules/virtualization.nix"
    "${flake}/modules/gaming.nix"
    "${flake}/modules/bluetooth.nix"

    "${flake}/modules/desktop/plasma6.nix"
    # "${flake}/modules/desktop/niri.nix" # breaks sddm
    "${flake}/modules/desktop/apps.nix"
  ];

  users.users.sandorex = {
    isNormalUser = true;
    description = "Sandorex";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # use zsh by default
  users.defaultUserShell = stable.zsh;
  programs.zsh.enable = true;

  system.stateVersion = "25.05";
}
