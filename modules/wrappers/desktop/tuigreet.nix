{ config, pkgs, lib, ... }:

# setup tuigreet the best greeter thingy
let
  # commands to autologin into specific desktop environments
  autologinCommands = {
    hyprland-uwsm = "uwsm start hyprland-uwsm.desktop";
    kde6 = "startplasma-wayland";
    sway = "sway";
    wayfire = "wayfire";
  };
in
{
  options.my.tuigreet = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use tuigreet greetd greeter";
    };

    autologin.desktop = lib.mkOption {
      default = null;
      type = with lib.types; nullOr (enum (builtins.attrNames autologinCommands));
      description = "Enable autologin to specific desktop enviroment";
    };

    autologin.user = lib.mkOption {
      default = config.my.user;
      type = lib.types.str;
      description = "User to autologin as";
    };

    kwallet.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Enable KWallet auto-unlock support";
    };
  };

  config = lib.mkIf config.my.tuigreet.enable {
    services.greetd =
      let
        autologinUser = config.my.tuigreet.autologin.user;
        autologinDesktop = config.my.tuigreet.autologin.desktop;

        # NOTE: without this all sessions appear twice
        baseSessionsDir = "${config.services.displayManager.sessionData.desktops}";
        xSessions = "${baseSessionsDir}/share/xsessions";
        waylandSessions = "${baseSessionsDir}/share/wayland-sessions";

        argsList = [
          "--user-menu"                                     # choose user using a menu
          "--asterisks"                                     # show * while typing password
          "--time"                                          # show time
          "--remember"                                      # remember last user
          "--remember-session"                              # remember last session
          "--sessions ${waylandSessions}:${xSessions}"
          "--session-wrapper \"systemd-cat -t desktop --\"" # print all output to systemd
        ];

        args = lib.concatStringsSep " " argsList;
      in {
        enable = true;
        useTextGreeter = true; # reduces messages during boot to not disrupt TUI
        settings = {
          initial_session = lib.mkIf (autologinDesktop != null) {
            command = autologinCommands.${autologinDesktop};
            user = autologinUser;
          };

          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet ${args}";
          };
        };
      };

    # allow kwallet to work
    security.pam.services.login.kwallet = lib.mkIf config.my.tuigreet.kwallet.enable {
      enable = true;
      forceRun = true;
    };

    security.pam.services.greetd.kwallet = lib.mkIf config.my.tuigreet.kwallet.enable {
      enable = true;
      forceRun = true;
    };
  };
}
