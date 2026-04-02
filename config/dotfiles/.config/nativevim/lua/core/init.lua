-- does not export any functions
require("core.functions")

return vim.tbl_deep_extend("error",
    {},
    require("core.utils"),
    require("core.chooser"),
    require("core.fuzzy")
)
