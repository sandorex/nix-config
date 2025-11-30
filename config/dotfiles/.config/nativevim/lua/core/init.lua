-- This file contains helpers and functions used in after/ files

local M = {}

function M.snippet(name, text)
    -- currently the simplest way to create snippets
    vim.keymap.set("n", "," .. name, function()
        -- basically insert snippet lines below cursor
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_lines(0, row, row, true, vim.fn.split(text, "\n"))
    end, { buffer = true })
end

--- Automatically maps pairs "{}" -> "{|}" with | being the cursor, works for
--- any length of pairs but cursor will always be after the first character
function M.map_autopairs(pairs)
    for _, i in ipairs(pairs) do
        vim.keymap.set("i", i:sub(1, 1), i .. string.rep("<left>", i:len() - 1), { buffer = true })
    end
end

return M

