{ config, lib, stable, ... }:

let
  inherit (builtins) map attrNames readDir readFile isString filter split replaceStrings concatStringsSep;

  rulesDir = ../config/rules;

  # used in the rules to make the dotfiles directory dynamic
  placeholder = "@dotfiles@";
  placeholderValue = "${config.dotfiles.path}/config/dotfiles";

  # gets names of all rule files
  ruleList = lib.pipe rulesDir [
    readDir
    attrNames
    (map (lib.removeSuffix ".conf"))
  ];

  rules = lib.pipe config.dotfiles.dotfiles [
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
  options = {
    dotfiles.path = lib.mkOption {
      default = "/home/${config.my.user}/nix-config";
      type = lib.types.str;
      description = "Path on host where dotfiles are stored";
      example = "/home/user/.dotfiles";
    };

    dotfiles.clone.url = lib.mkOption {
      default = "https://github.com/sandorex/nix-config";
      type = lib.types.str;
      description = "Path on host where dotfiles are stored";
      example = "https://github.com/user/dotfiles";
    };

    dotfiles.clone.enable = lib.mkEnableOption "Clone repository automatically";

    dotfiles.dotfiles = lib.mkOption {
      type = lib.types.submodule {
        options = lib.genAttrs ruleList (rule: {
          enable = lib.mkEnableOption "dotfiles for ${rule}";
        });
      };
      default = {};
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
    (lib.mkIf (rules != []) {
      systemd.user.tmpfiles.users.${config.my.user}.rules = rules;
    })
    (lib.mkIf (config.dotfiles.clone.enable) {
      system.userActivationScripts = {
        # clone repository if it does not exist
        dotfilesClone = ''
          [ -e "${config.dotfiles.path}" ] || ${stable.git} clone "${config.dotfiles.clone.url}" "${config.dotfiles.path}"
        '';
      };
    })
  ];
}
