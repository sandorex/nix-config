-- contains code for buffer chooser

-- TODO keybindings

local M = {}

-- i think realisticly you wont have more bufffers than choices?
local key_choices = {
    -- -- numbers
    -- '1', '2', '3', '4', '5', '6', '7', '8', '9',

    -- lowercase letters
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'w', 'x', 'y', 'z',

    -- uppercase letters
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z',
}

local function tbl_find(val, tbl)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return nil
end

-- TODO this should be part of core api
function M.open_menu(options, format_callback, callback)
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 80
    local height = #options
    local ui = vim.api.nvim_list_uis()[1]
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width - width) / 2,
        row = (ui.height - height) / 2,
        style = 'minimal',
        border = 'rounded',
        title = ' Select buffer ',
        title_pos = 'center',
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    local options_lines = {}
    for i, item in ipairs(options) do
        options_lines[i] = key_choices[i] .. ') ' .. format_callback(item)
    end

    -- write text to the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, options_lines)

    -- TODO there is no way to hide the cursor right now
    -- set options so it is more like an application than text buffer
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'cursorline', false)

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end

        vim.on_key(nil, vim.api.nvim_create_namespace("menu_listener"))
    end

    -- this runs every time a key is pressed anywhere in neovim
    vim.on_key(function(key)
        -- if window lost focus just close
        if vim.api.nvim_get_current_win() ~= win then
            vim.schedule(close)
        end

        -- if key is one of the allowed choices do the thing
        local index = tbl_find(key, key_choices)
        if index and index > 0 then
            callback(options[index])
        end

        -- always quit after keypress
        vim.schedule(close)

        -- always return empty string to prevent default key actions
        return ""
    end, vim.api.nvim_create_namespace("menu_listener"))
end

function M.get_buffers_by_last_used()
    local bufs = vim.api.nvim_list_bufs()
    local result = {}

    for _, buf in ipairs(bufs) do
        -- only show listed and valid buffers
        -- also do not include current buffer
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and buf ~= vim.api.nvim_get_current_buf() then
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

-- @param show_if_one should the menu be shown if there is only one buffer
function M.choose_buffer(show_if_one)
    local sorted_bufs = M.get_buffers_by_last_used()

    if not sorted_bufs or #sorted_bufs == 0 then
        print("No buffers found")
        return
    end

    -- just switch if there is only one buffer open
    if #sorted_bufs == 1 and not show_if_one then
        vim.schedule(function()
            vim.cmd(":b " .. sorted_bufs[1].buf)
        end)

        return
    end

    M.open_menu(sorted_bufs,
        function(item)
            local name = item.name
            if name == '' or not name then
                name = '[unnamed]'
            else
                -- make the filename relative to current dir or home
                name = vim.fn.fnamemodify(item.name, ':~:.')
            end

            return name
        end,
        function(choice)
            if choice then
                vim.schedule(function()
                    vim.cmd(":b " .. choice.buf)
                end)
            else
                print("ChooserBuffer cancelled")
            end
        end
    )
end

return M
