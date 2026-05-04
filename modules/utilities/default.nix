{ ... }:

{
  imports = [
    ./update-reminder.nix
    ./auto-updater.nix
    ./disky.nix
    ./dotfiles.nix
    ./serial.nix
    ./garbage.nix
    ./flatpak.nix
    ./vfio.nix
  ];
}
