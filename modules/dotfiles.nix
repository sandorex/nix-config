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

    # get only file names
    attrNames

    # filter only conf files
    (filter (name: (lib.hasSuffix ".conf" name)))

    # remove suffix
    (map (lib.removeSuffix ".conf"))
  ];
in
{
  options = {
    dotfiles.placeholder = lib.mkOption {
      default = placeholder;
      type = lib.types.str;
      readOnly = true;
      internal = true;
      description = "Placeholder value which is replaced by actual dotfiles path";
    };

    dotfiles.configs = lib.mkOption {
      default = (lib.genAttrs ruleList
        (rule: lib.pipe "${rulesDir}/${rule}.conf" [
          readFile
        
          # split into lines
          (split "\n")

          # filter comments and empty lines
          (filter (line: (isString line) && line != "" && !(lib.hasPrefix "#" line)))
        ])
      );
      type = lib.types.attrs;
      readOnly = true;
      internal = true;
      description = "Contains all dotfiles rules";
    };

    dotfiles.enabled = lib.mkOption {
      type = with lib.types; listOf (listOf str);
      default = [];
      description = "List of lists of lines that are added to user systemd-tmpfiles but with expanded placeholder";
    };
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
    (lib.mkIf (config.dotfiles.enabled != []) {
      systemd.user.tmpfiles.users.${config.my.user}.rules = (
        lib.pipe config.dotfiles.enabled [
          lib.flatten

          # concat all lists into one string
          (concatStringsSep "\n")

          # replace the placeholder
          (replaceStrings [placeholder] [placeholderValue])

          # split into lines
          (split "\n")

          # filter empty arrays
          (filter isString)
        ]
      );
    })
  ];
}
