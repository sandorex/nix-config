local core = require("core.utils")

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()" })

core.snippet("mod", [[
local M = {}

return M
]])

