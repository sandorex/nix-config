# adds ssh and forcibly creates the systemd service if ssh was not already
# enabled, then it does nothing
{lib, config, ...}:

{  
  systemd.services.sshd.wantedBy = lib.mkIf config.services.openssh.enable (lib.mkForce []);
  
  # in case it was not enabled already enable it
  services.openssh.enable = true;
}
