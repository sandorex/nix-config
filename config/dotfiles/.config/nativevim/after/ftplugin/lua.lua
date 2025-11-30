local core = require("core")

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()" })

core.snippet("mod", [[
local M = {}

return M
]])

