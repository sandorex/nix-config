{ config, lib, ... }:

let
  enable = config.my.sshd.enable;
in
{
  options.my.sshd.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = "Enables sshd autostart (it is always installed)";
  };

  config = {
    systemd.services.sshd.wantedBy = lib.mkIf (!enable) (lib.mkForce []);
    services.sshd.enable = true;
  };
}
