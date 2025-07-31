{ config, pkgs, lib, ... }:

# setup tuigreet the best greeter thingy
let
  # commands to autologin into specific desktop environments
  autologinCommands = {
    hyprland-uwsm = "uwsm start hyprland-uwsm.desktop";
    kde6 = "startplasma-wayland";
    sway = "sway";
  };
in
{
  options = {
    my.tuigreet.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use tuigreet greetd greeter";
    };

    my.tuigreet.autologin.desktop = lib.mkOption {
      default = null;
      type = with lib.types; nullOr (enum (builtins.attrNames autologinCommands));
      description = "Enable autologin to specific desktop enviroment";
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
        autologinCommand = autologinCommands.${config.my.tuigreet.autologin.desktop};
      
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
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet ${args}";
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
