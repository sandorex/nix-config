local core = require("core")
local opt = vim.opt

-- 2 spaces indentation
opt.tabstop = 2
opt.expandtab = true

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()" })

