{ stable, ... }:

{
  programs.steam.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = false; # does not work "operation not permitted"
  };

  environment.systemPackages = with stable; [
    mangohud
  ];
}
