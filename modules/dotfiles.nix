{ config, lib, ... }:

let
  # TODO assumed location try to get it somehow or just check it?
  # configDir = "/home/${config.my.user}/nix-config/config/configs";
  # configDir = ../config/configs
  dotfilesDir = "/home/${config.my.user}/nix-config/config/dotfiles";

  configDir = ../config/rules;
  configSuffix = ".conf";
  configPlaceholder = "@dotfiles@";

  ruleNames = builtins.map (x: lib.strings.removeSuffix configSuffix x) (builtins.attrNames (builtins.readDir configDir));
  _ = builtins.trace ruleNames null;

  configContents = builtins.map (x: builtins.readFile "${configDir}/${x}${configSuffix}") (builtins.map (x: toString x) config.dotfiles.enabled);

  rulesFilter = line: (builtins.isString line) && line != "" && !(lib.strings.hasPrefix "#" line);
  # rules = builtins.concatStringsSep "\n" ruleFileContents;

  # builtins.map (x: nixpkgs.lib.strings.removeSuffix x) (builtins.attrNames (builtins.readDir ./config/configs))
  # TODO use replaceStrings
in
{
  options = {
    dotfiles.enabled = lib.mkOption {
      default = [];
      type = with lib.types; listOf (enum ruleNames); # allow only valid configs
      description = "Which dotfiles to install";
    };
  };

  config = lib.mkIf (config.dotfiles.enabled != []) {
    systemd.user.tmpfiles.users.${config.my.user}.rules = (builtins.filter rulesFilter (builtins.split "\n" (builtins.replaceStrings [configPlaceholder] [dotfilesDir] (builtins.concatStringsSep "\n" configContents))));
  };
}
