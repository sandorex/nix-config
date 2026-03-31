-- contains code for buffer chooser

local utils = require("core.extras.utils")
local M = {}

M.chooser_keymaps = {
    -- letters on left part of the keyboard
    left = {
        'q', 'w', 'e', 'r',
        'a', 's', 'd', 'f',
        'z', 'x', 'c', 'v',
        'Q', 'W', 'E', 'R',
        'A', 'S', 'D', 'F',
        'Z', 'X', 'C', 'V',
    },

    -- only numbers
    numeric = {
        "1", "2", "3", "4", "5", "6", "7", "8", "9",
    },

    -- numbers and letters
    alphanumeric = {
        "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    },
}

-- TODO add option to ask user for confirmation for more dangerous things
function M.chooser(title, keymap, options, format_callback, callback)
    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]

    -- responsive size
    local width = math.min(80, ui.width)
    local height = math.min(#options, ui.height - 4)

    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width - width) / 2,
        row = (ui.height - height) / 2,
        style = 'minimal',
        border = 'bold',
        title = ' ' .. title .. ' ',
        title_pos = 'center',
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end

        -- TODO should the namespace be the same? saved somewhere?
        vim.on_key(nil, vim.api.nvim_create_namespace("chooser"))
    end

    -- this runs every time a key is pressed anywhere in neovim
    vim.on_key(function(key)
        -- if window lost focus just close
        if vim.api.nvim_get_current_win() ~= win then
            close()
        end

        -- if key is one of the allowed choices do the thing
        local index = utils.tbl_find(key, keymap)
        if index and index > 0 then
            callback(options[index])
        end

        -- always quit after keypress
        close()

        -- always return empty string to prevent default key actions
        return ""
    end, vim.api.nvim_create_namespace("chooser"))

    local lines = {}
    for i, item in ipairs(options) do
        -- in case there are too many options just show without any keys
        if i > #keymap then
            lines[i] = ' ) ' .. format_callback(item)
        else
            lines[i] = ' ' .. keymap[i] .. ') ' .. format_callback(item)
        end
    end

    -- write text to the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- TODO there is no way to hide the cursor right now
    -- set options so it is more like an application than text buffer
    -- vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    -- vim.api.nvim_buf_set_option(buf, 'cursorline', false)
    vim.api.nvim_set_option_value("modifiable", false, { scope = "local", buf = buf })

    vim.api.nvim_set_option_value("cursorline", false, { scope = "local", win = win })

    -- allow moving cursor past text to hide it
    vim.api.nvim_set_option_value("virtualedit", "all", { scope = "local", win = win })

    -- move the cursor so its not in the way
    vim.api.nvim_win_set_cursor(win, {1, width - 1})
end

-- @param show_if_one should the menu be shown if there is only one buffer
local function choose_buffer(show_if_one)
    local sorted_bufs = utils.get_buffers_by_last_used()

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

    M.chooser(
        "Select buffer",
        M.chooser_keymaps.left,
        sorted_bufs,
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

vim.api.nvim_create_user_command("ChooseBuffer", function() choose_buffer(false) end, { desc = "Choose buffer" })

return M
