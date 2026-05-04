local core = require("core.utils")
local opt = vim.opt

-- 2 spaces indentation
opt.tabstop = 2
opt.expandtab = true

-- autocomplete pairs
core.map_autopairs({ '""', "{}", "[]", "()" })

-- snippets
core.snippet("option", [[
lib.mkOption {
  description = "${0:Something}";
  type = with lib.types; listOf str;
  default = [];
  example = [ "" ];
}
]])
core.snippet("option", [[lib.mkEnableOption "${0:Something}"]])
core.snippet("flake", [[
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit self;
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
    in
    {
    };
}
]])

