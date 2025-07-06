{ config, stable, lib, ... }:

# setup tuigreet the best greeter thingy
{
  config = lib.mkIf config.my.tuigreet.enable {
    services.greetd =
      let
        argsList = [
          "--user-menu"        # choose user using a menu
          "--asterisks"        # show * while typing password
          "--time"             # show time
          "--remember"         # remember last user
          "--remember-session" # remember last session
        ];

        # convert list of strings to single string with spaces between elements
        args = lib.concatStrings (lib.strings.intersperse " " argsList);
      in {
        enable = true;
        vt = 2; # bootup is noisy so just use another tty
        settings = {
          default_session = {
            command = "${stable.greetd.tuigreet}/bin/tuigreet ${args}";
          };
        };
      };
  };
}
