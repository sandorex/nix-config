-- basically all user commands are defined here lazily so the modules do not
-- need to be loaded when they are not used

-- returns a function that lazily loads the module and runs the function
-- lazy.<mod>.<func>
local lazy = setmetatable({}, {
    __index = function(_, mod)
        return setmetatable({}, {
            __index = function(_, fn)
                return function(...)
                    return require("core." .. mod)[fn](...)
                end
            end,
        })
    end,
})

local cmd = vim.api.nvim_create_user_command

local fuzzy = lazy.fuzzy
cmd("FuzzyBuffer", fuzzy.cmd_fuzzy_buffer, { desc = "Switch to buffer (fuzzy)" })
cmd("FuzzyFile", fuzzy.cmd_fuzzy_file, { desc = "Edit file (fuzzy)", nargs="?" })
cmd("FuzzyMap", fuzzy.cmd_fuzzy_map, { desc = "Search mapped keybindings (fuzzy)" })
cmd("FuzzySnippet", fuzzy.cmd_fuzzy_snippets, { desc = "Search snippets (fuzzy)" })

local chooser = lazy.chooser
vim.api.nvim_create_user_command("ChooseBuffer", chooser.cmd_choose_buffer, { desc = "Switch to buffer" })
