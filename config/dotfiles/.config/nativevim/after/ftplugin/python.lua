local core = require("core")

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()" })

core.snippet("dir", [[
import pathlib
ROOT = pathlib.Path(__file__).parent.resolve()
]])

