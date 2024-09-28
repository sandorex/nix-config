# note ssh is not automatically started but the systemctl service is created
{lib, ...}:

{
  services.openssh.enable = true;
  
  # create systemd service for SSH but do not start it automatically
  systemd.services.sshd.wantedBy = lib.mkForce [];
}
