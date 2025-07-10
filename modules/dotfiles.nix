{ config, lib, stable, ... }:

let
  inherit (builtins) map attrNames readDir readFile isString filter split replaceStrings concatStringsSep;

  rulesDir = ../config/rules;

  # used in the rules to make the dotfiles directory dynamic
  placeholder = "@dotfiles@";
  placeholderValue = "${config.my.localPath}/config/dotfiles";

  # gets names of all rule files
  ruleList = lib.pipe rulesDir [
    readDir
    attrNames
    (map (lib.removeSuffix ".conf"))
  ];

  rules = lib.pipe config.dotfiles [
    # filter only enabled
    (lib.filterAttrs (_: v: v.enable))

    # get only names
    attrNames

    # read every rule file
    (map (x: readFile "${rulesDir}/${x}.conf"))

    # add them together
    (concatStringsSep "\n")

    # replace the placeholder
    (replaceStrings [placeholder] [placeholderValue])

    # split into lines
    (split "\n")

    # filter comments and empty lines
    (filter (line: (isString line) && line != "" && !(lib.hasPrefix "#" line)))
  ];
in
{
  options.dotfiles = lib.mkOption {
    type = lib.types.submodule {
      options = lib.genAttrs ruleList (rule: {
        enable = lib.mkEnableOption "dotfiles for ${rule}";
      });
    };
    default = {};
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = ruleList != [];
          message = "No dotfiles rules found!";
        }
      ];
    }
    (lib.mkIf (rules != []) {
      systemd.user.tmpfiles.users.${config.my.user}.rules = rules;
    })
  ];
}
