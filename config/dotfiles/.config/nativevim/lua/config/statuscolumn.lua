-- contains statuscolumn config
-- i tend to skim text using the mouse so why not make it more pleasent

local M = {}

-- toggle fold when clicking on linenum (if possible)
function _G.my_statuscolumn_line(minwid, clicks, button, mods)
    local line = vim.fn.getmousepos().line

    -- NOTE silent! is to prevent error messages
    if button == "l" or button == "r" then
        -- close/open only single level
        if vim.fn.foldclosed(line) == -1 then
            vim.cmd[[ silent! foldclose ]]
        else
            vim.cmd[[ silent! foldopen ]]
        end
    end
end

-- open diagnostics when clicking on sign column
function _G.my_statuscolumn_sign(minwid, clicks, button, mods)
    vim.schedule(function()
        vim.diagnostic.open_float()
    end)
end

vim.o.statuscolumn = "%@v:lua.my_statuscolumn_sign@%s%X%@v:lua.my_statuscolumn_line@%l%X "

return M
