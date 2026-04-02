local utils = require("core.extras.utils")
local M = {}

--- Opens floating fuzzy chooser
function M.fuzzy_chooser(options)
    local opts = options or {}

    vim.validate("opts.options", opts.options, "table")
    vim.validate("opts.title", opts.title, "string", true)
    vim.validate("opts.callback", opts.callback, "function")
    vim.validate("opts.map", opts.map, "function", true)

    local orig_options = opts.options
    local title = opts.title or "Fuzzy chooser"
    local callback = opts.callback
    local map = opts.map

    -- if map function is provided then map all options
    local lines = {}
    if map then
        for i, option in ipairs(orig_options) do
            lines[i] = map(option)
        end
    else
        lines = orig_options
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]

    -- special prompt buffer
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
    vim.fn.prompt_setprompt(buf, "> ")

    -- responsive size
    local width = math.min(80, ui.width)
    local height = math.min(80, ui.height - 4)

    local function render(query)
        local formatted = {}
        if query ~= nil and query ~= "" then
            formatted = vim.fn.matchfuzzy(lines, query)
        else
            formatted = lines
        end

        -- write text to the buffer (making sure not to overwrite the prompt)
        vim.api.nvim_buf_set_lines(buf, 0, -2, false, formatted)

        -- return first line
        return formatted[1]
    end

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width - width) / 2,
        row = (ui.height - height) / 2,
        style = 'minimal',
        border = 'bold',
        title = ' ' .. title .. ' ',
        title_pos = 'center',
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    -- close on escape
    vim.keymap.set({"n", "i"}, "<Esc>", close, { buffer = buf })

    vim.fn.prompt_setcallback(buf, function(text)
        -- render again and get the first line
        local target = render(text)

        -- find the option
        local index = utils.tbl_find(target, lines)
        if index ~= nil then
            callback(index)
        else
            error("The first line is not valid option")
        end

        -- close the window
        close()
    end)

    -- search on idle
    vim.api.nvim_create_autocmd("CursorHoldI", {
        buffer = buf,
        callback = function()
            local query = vim.api.nvim_get_current_line():sub(3)
            render(query)
        end,
    })

    render(nil)

    -- start insert mode on launch
    vim.cmd("startinsert")
end

-- TODO accept root for searching for files for relative
-- @param show_if_one should the menu be shown if there is only one buffer
local function fuzzy_buffer(show_if_one)
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

    M.fuzzy_chooser {
        title = "Select buffer (fuzzy)",
        options = sorted_bufs,
        map = function(buf)
            if vim.startswith(buf.name, "/") then
                return vim.fn.fnamemodify(buf.name, ':~:.')
            else
                return buf.name
            end
        end,
        callback = function(index)
            vim.schedule(function()
                vim.cmd("buffer " .. sorted_bufs[index].buf)
            end)
        end,
    }
end

vim.api.nvim_create_user_command("FuzzyBuffer", function() fuzzy_buffer(false) end, { desc = "Choose buffer (fuzzy)" })

local function find_files_rg(root)
    local list = { "rg", "--color", "never", "--files", "--fixed-strings" }
    if root ~= nil and root ~= "" then table.insert(list, root) end

    return vim.fn.systemlist(list)
end

local function find_files_find(root)
    local list = { "find", (root or "."), "-type", "f", "-or", "-type", "l" }

    return vim.fn.systemlist(list)
end

-- automatically use rg if available
local find_files
if vim.fn.executable("rg") == 1 then
    find_files = find_files_rg
else
    find_files = find_files_find
end

local function fuzzy_files()
    local files = find_files()

    M.fuzzy_chooser {
        title = "Select file (fuzzy)",
        options = files,
        map = function(buf)
            if vim.startswith(buf, "/") then
                return vim.fn.fnamemodify(buf, ':~:.')
            else
                return buf
            end
        end,
        callback = function(index)
            vim.schedule(function()
                vim.cmd(":e " .. files[index])
            end)
        end,
    }
end

vim.api.nvim_create_user_command("FuzzyFiles", function() fuzzy_files() end, { desc = "Choose file (fuzzy)" })

return M
