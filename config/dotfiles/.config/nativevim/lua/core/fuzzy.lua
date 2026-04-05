local utils = require("core.utils")
local const = require("core.constants")
local M = {}

-- default depth to traverse
M.default_depth = 5

-- depth to traverse in case of a timeout
M.timeout_depth = 2

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
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
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

        if vim.api.nvim_win_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
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

-- @param show_if_one should the menu be shown if there is only one buffer
local function fuzzy_buffer(show_if_one)
    local sorted_bufs = utils.get_buffers_by_last_used()

    if not sorted_bufs or #sorted_bufs == 0 then
        vim.notify("No buffers found", vim.log.levels.WARN)
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

local function find_files_rg(root, max_depth, timeout)
    local cmd = {
        "rg",
        "--color", "never",
        "--max-depth=" .. (max_depth or const.max_depth),
        "--files",
        "--fixed-strings"
    }
    if root ~= nil and root ~= "" then table.insert(cmd, root) end

    local obj = vim.system(cmd, {
        text = true,
        timeout = (timeout or const.timeout),
    }):wait()

    if obj.code == 124 and obj.signal == 15 then
        -- return existing data but signify that timeout has happened
        return vim.split(obj.stdout, "\n"), true
    elseif obj.code ~= 0 then
        error("Ripgrep command exited with code " .. obj.code)
    end

    return vim.split(obj.stdout, "\n"), false
end

-- automatically use rg if available
local find_files
if vim.fn.executable("rg") == 1 then
    find_files = find_files_rg
else
    -- fallback to pure lua version
    find_files = require("core.find").find_files
end

local function fuzzy_file(root)
    local files, timeout = find_files(root)

    if timeout == true then
        vim.notify("Warning: timeout searching for files", vim.log.levels.WARN)
    end

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
                vim.cmd("edit " .. files[index])
            end)
        end,
    }
end

vim.api.nvim_create_user_command(
    "FuzzyFile",
    function(args)
        if args.args and args.args ~= "" then
            fuzzy_file(args.args)
        else
            fuzzy_file()
        end
    end,
    { desc = "Choose file (fuzzy)", nargs="?" }
)

local function fuzzy_map()
    local lines = {}

    local function add_key(key)
        local desc = ""
        if key.desc then
            desc = " - " .. key.desc
        end

        local rhs = ""
        if type(key.rhs) == "string" then
            rhs = " '" .. key.rhs .. "'"
        end

        -- TODO maybe add padding to lhs and rhs?
        table.insert(lines, string.format(
            "%-3s '%s'%s%s",
            key.mode,
            key.lhs,
            rhs,
            desc
        ))
    end

    -- add keys for all the modes
    for _, mode in ipairs({ "n", "i", "l", "v", "s", "x", "o", "c", "t" }) do
        for _, key in ipairs(vim.api.nvim_get_keymap(mode)) do
            add_key(key)
        end
    end

    M.fuzzy_chooser {
        title = "Find mapping (fuzzy)",
        options = lines,
        callback = function(_)
            -- do nothing as there's nothing to do?
        end,
    }
end

vim.api.nvim_create_user_command("FuzzyMap", fuzzy_map, { desc = "Search mapped keys (fuzzy)" })

return M
