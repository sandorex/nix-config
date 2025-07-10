{ config, stable, lib, ... }:

# setup tuigreet the best greeter thingy
{
  options = {
    my.tuigreet.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use tuigreet greetd greeter";
    };

    # commands to use
    # kde: startplasma-wayland
    # hyprland: hyprland
    my.tuigreet.autologin.command = lib.mkOption {
      default = null;
      type = with lib.types; nullOr (str);
      description = "Enables autologin with this command";
    };

    my.tuigreet.autologin.user = lib.mkOption {
      default = config.my.user;
      type = lib.types.str;
      description = "User to autologin as";
    };
  };

  config = lib.mkIf config.my.tuigreet.enable {
    services.greetd =
      let
        autologinUser = config.my.tuigreet.autologin.user;
        autologinCommand = config.my.tuigreet.autologin.command;
      
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
          initial_session = lib.mkIf (autologinCommand != null) {
            command = autologinCommand;
            user = autologinUser;
          };

          default_session = {
            command = "${stable.greetd.tuigreet}/bin/tuigreet ${args}";
          };
        };
      };

    # allow kwallet to work
    security.pam.services.login.kwallet = {
      enable = true;
      forceRun = true;
    };
    security.pam.services.greetd.kwallet = {
      enable = true;
      forceRun = true;
    };
  };
}
