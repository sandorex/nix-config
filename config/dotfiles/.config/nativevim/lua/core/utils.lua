local M = {}

--- Creates a keybinding for the snippet
function M.snippet(name, text, desc)
    local description = nil
    if desc and desc ~= "" then
        -- so its clear its a snippet
        description = desc .. " (snippet)"
    end

    -- currently the simplest way to create snippets
    -- the ending comma is to prevent waiting for timeoutlen when for example
    -- snippets 'sh' and 'shell' are available
    vim.keymap.set("n", "," .. name .. ",", function()
        -- basically paste snippet
        vim.api.nvim_paste(text, false, -1)
    end, { buffer = true, desc = description })
end

--- Automatically maps pairs "{}" -> "{|}" with | being the cursor, works for
--- any length of pairs but cursor will always be after the first character
function M.map_autopairs(pairs)
    for _, i in ipairs(pairs) do
        vim.keymap.set("i", i:sub(1, 1), i .. string.rep("<left>", i:len() - 1), { buffer = true })
    end
end

-- TODO would using getbufinfo alone be more efficient?
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
                lastused = info.lastused,
                changed = info.changed,
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
