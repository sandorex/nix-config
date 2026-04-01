-- contains code for buffer chooser

local utils = require("core.extras.utils")
local M = {}

M.chooser_keymaps = {
    -- characters easily reachable by the left hand
    left = {
        "q", "w", "e", "r", "t",
        "a", "s", "d", "f", "g",
        "z", "x", "c", "v", "b",
        "Q", "W", "E", "R", "T",
        "A", "S", "D", "F", "G",
        "Z", "X", "C", "V", "B",

        -- these are just in case the list is long..
        "1", "2", "3", "4", "5",
        "!", "@", "#", "$", "%"
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

-- TODO highlight key for each choice
-- TODO make options a dict and validate using vim.validate
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

    local lines = {}
    for i, item in ipairs(options) do
        -- limit to screen size
        if i > height then
            break
        end

        -- in case there are too many options just show without any keys
        if i > #keymap then
            lines[i] = ' ) ' .. format_callback(item)
        else
            lines[i] = ' ' .. keymap[i] .. ') ' .. format_callback(item)
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { scope = "local", buf = buf })
    vim.api.nvim_win_set_buf(win, buf)

    -- force redraw so new window is shown
    vim.cmd("redraw")

    -- NOTE i do not need special keys here so im not using nr2char
    local ch = vim.fn.getcharstr(-1)

    -- find the index of key and call callback if valid
    local index = utils.tbl_find(ch, keymap)
    if index and index > 0 and index <= #options then
        callback(options[index])
    end

    -- always close afterwards
    vim.api.nvim_win_close(win, true)
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
            vim.schedule(function()
                vim.cmd(":b " .. choice.buf)
            end)
        end
    )
end

vim.api.nvim_create_user_command("ChooseBuffer", function() choose_buffer(false) end, { desc = "Choose buffer" })

return M
