-- does not export any functions
require("core.extras.functions")

return vim.tbl_deep_extend("error",
    {},
    require("core.extras.utils"),
    require("core.extras.chooser"),
    require("core.extras.fuzzy")
)
