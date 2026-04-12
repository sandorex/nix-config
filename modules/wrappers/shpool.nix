{ config, lib, pkgs, ... }:

let
  enable = config.my.shpool.enable;
  autostart = config.my.shpool.autostart;
in
{
  options.my.shpool = {
    enable = lib.mkEnableOption "Enable shpool";
    autostart = lib.mkEnableOption "Enable autostart of shpool daemon";
  };

  config = lib.mkIf enable {
    environment.systemPackages = [ pkgs.shpool ];

    systemd.user = {
      services.shpool = {
        description = "Shpool - Shell Session Pool";
        requires = [ "shpool.socket" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe pkgs.shpool} daemon";
          KillMode = "mixed";
          TimeoutStopSec = "2s";
          SendSIGHUP = true;
        };

        # autostart on demand
        wantedBy = if autostart then [ "default.target" ] else [];
      };

      sockets.shpool = {
        description = "Shpool Shell Session Pooler";

        socketConfig = {
          ListenStream = "%t/shpool/shpool.socket";
          SocketMode = "0600";
          RemoveOnStop = "yes";
          FlushPending = "yes";
        };

        wantedBy = [ "sockets.target" ];
      };
    };
  };
}
