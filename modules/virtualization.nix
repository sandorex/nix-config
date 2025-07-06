{ ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "sandorex" ]; # TODO get the default user name somehow?
}
