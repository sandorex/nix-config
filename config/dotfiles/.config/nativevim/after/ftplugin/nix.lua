local core = require("core.utils")
local opt = vim.opt

-- 2 spaces indentation
opt.tabstop = 2
opt.expandtab = true

-- autocomplete pairs
core.map_autopairs({ '""', "{}", "[]", "()" })

-- snippets
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

