local core = require("core.utils")

-- autocomplete pairs
core.map_autopairs({ '""', "''", "{}", "[]", "()" })

core.snippet("dir", [[
import pathlib
ROOT = pathlib.Path(__file__).parent.resolve()
]])

