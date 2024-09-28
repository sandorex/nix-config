{stable, ...}:

{
  environment.shells = with stable; [ bash zsh ];
  users.defaultUserShell = stable.zsh;
  programs.zsh.enable = true;
}
