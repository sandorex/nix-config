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

function M.get_buffers_by_last_used()
    local bufs = vim.api.nvim_list_bufs()
    local result = {}

    for _, buf in ipairs(bufs) do
        -- only show listed and valid buffers
        -- also do not include current buffer
        if vim.api.nvim_buf_is_valid(buf)
                and vim.bo[buf].buflisted
                and buf ~= vim.api.nvim_get_current_buf() then
            local info = vim.fn.getbufinfo(buf)[1]
            table.insert(result, {
                buf = buf,
                name = info.name,
                lastused = info.lastused
            })
        end
    end

    -- sort the files by most recent
    table.sort(result, function(a, b)
        return a.lastused > b.lastused
    end)

    return result
end

function M.tbl_find(val, tbl)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return nil
end

return M
