{ config, stable, lib, ... }:

# setup tuigreet the best greeter thingy
{
  services.greetd =
    let
      # NOTE: without this all sessions appear twice
      baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
      xSessions = "${baseSessionsDir}/share/xsessions";
      waylandSessions = "${baseSessionsDir}/share/wayland-sessions";

      argsList = [
        "--user-menu"        # choose user using a menu
        "--asterisks"        # show * while typing password
        "--time"             # show time
        "--remember"         # remember last user
        "--remember-session" # remember last session
        "--sessions ${waylandSessions}:${xSessions}"
      ];

      args = lib.concatStringsSep " " argsList;
    in {
      enable = true;
      vt = 2; # bootup is noisy so just use another tty
      settings = {
        initial_session = {
          command = "${stable.kdePackages.plasma-workspace}/bin/startplasma-wayland";
          user = "sandorex";
        };

        default_session = {
          command = "${stable.greetd.tuigreet}/bin/tuigreet ${args}";
        };
      };
    };
}
