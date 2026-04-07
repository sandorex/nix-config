local core = require("core.utils")
local opt = vim.opt

-- 2 spaces indentation
opt.tabstop = 2
opt.expandtab = true

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()", "<>" })

-- snippets
core.snippet("html", [[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welp</title>
    <link rel="stylesheet" href="index.css">
  </head>
  <body>
    <p>Here we go again</p>
    <script src="index.js"></script>
  </body>
</html>
]])
