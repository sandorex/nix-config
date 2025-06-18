{ stable, ... }:

{
  programs.steam.enable = true;

  environment.systemPackages = with stable; [
    mangohud
  ];
}
