local utils = require("core.utils")
local const = require("core.constants")
local ns = vim.api.nvim_create_namespace("fuzzy")

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
    -- vim.hl.range(buf, ns, "String", {0,0}, {4,0}, { priority = 400 })

    -- start insert mode on launch
    vim.cmd("startinsert")
end

-- TODO use map with keys being index in original so i dont have to copy it so many times
-- this list can be edited by user
--- The choices available to the chooser
M.choices = nil

-- while this list is hidden as it is used for finding the index
local choices_orig = nil

local win1 = nil
local buf1 = nil
local win2 = nil
local buf2 = nil
local last_query = ""

function M.close()
    if win1 ~= nil and vim.api.nvim_win_is_valid(win1) then
        vim.api.nvim_win_close(win1, true)
    end

    if win2 ~= nil and vim.api.nvim_win_is_valid(win2) then
        vim.api.nvim_win_close(win2, true)
    end

    -- exit insert mode when leaving the chooser
    vim.cmd("stopinsert")

    -- remove any leftover data
    M.choices = nil
    choices_orig = nil
end

local function create_windows(title, prompt)
    M.close()

    local ui = vim.api.nvim_list_uis()[1]

    buf1 = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf1, "bufhidden", "wipe")

    buf2 = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf2, "bufhidden", "wipe")

    local height = math.min(vim.o.pumheight, ui.height)

    local row = ui.height - vim.o.cmdheight - 1
    win1 = vim.api.nvim_open_win(buf1, false, {
        relative = 'editor',
        width = ui.width,
        height = height,
        row = row - 2, -- allow space for window 2
        col = 0,
        anchor = "SW",
        focusable = false, -- do not allow focusing
        mouse = true, -- allow mouse selection
        style = 'minimal',
        title = ' ' .. title .. ' ',
        title_pos = 'center',
        zindex = 100,
    })

    -- highlight selected line
    vim.wo[win1].cursorline = true

    win2 = vim.api.nvim_open_win(buf2, true, {
        relative = 'editor',
        width = ui.width,
        height = 1,
        row = row,
        col = 0,
        anchor = "SW",
        style = 'minimal',
        zindex = 105, -- show on top of the other window
    })

    -- show prompt before the first line
    vim.api.nvim_buf_set_extmark(buf2, ns, 0, 0, {
        virt_text = { { prompt, "" } },
        virt_text_pos = "inline",
        right_gravity = false,
    })
end

--- Move cursor linewise (used to select different item)
function M.move_cursor_y(amount)
    local line_count = vim.api.nvim_buf_line_count(buf1)
    local y = vim.api.nvim_win_get_cursor(win1)[1] + amount

    -- guard against going outside buffer bounds
    vim.api.nvim_win_set_cursor(win1, { math.max(1, math.min(y, line_count)), 0 })
end

--- Refreshes items order, resetting the cursor position in meantime
function M.refresh(lazy)
    -- use whole input buffer just in case something with newlines is pasted in
    local query = table.concat(vim.api.nvim_buf_get_lines(buf2, 0, -1, false))

    -- do not compute if the query is the same
    if query == last_query and lazy == true then
        return
    end

    -- update last query
    last_query = query

    -- do the fuzzy searching if possible
    local formatted = {}
    if query ~= nil and query ~= "" then
        formatted = vim.fn.matchfuzzy(M.choices, query)
    else
        formatted = M.choices
    end

    -- write text to the buffer
    vim.api.nvim_buf_set_lines(buf1, 0, -1, false, formatted)

    -- reset selection as they things might have changed
    vim.api.nvim_win_set_cursor(win1, { 1, 0 })
end

--- Get index of selected item
function M.get_selected_index()
    local cursor_y = vim.api.nvim_win_get_cursor(win1)[1]
    local line = vim.api.nvim_buf_get_lines(buf1, cursor_y - 1, cursor_y, false)[1]

    -- find the index in original list
    return utils.tbl_find(line, choices_orig)
end

--- Get index of selected item after mouse press
function M.get_mouse_selected_index()
    local mousepos = vim.fn.getmousepos()
    if mousepos.winid == win1 and mousepos.line > 0 then
        local line = vim.api.nvim_buf_get_lines(buf1, mousepos.line - 1, mousepos.line, false)[1]

        -- find the index in original list
        return utils.tbl_find(line, choices_orig)
    else
        return nil
    end
end

function M.fuzzy_chooser2(options)
    local opts = options or {}

    vim.validate("opts.options", opts.options, "table")
    vim.validate("opts.update", opts.update, "string", true)
    vim.validate("opts.title", opts.title, "string", true)
    vim.validate("opts.prompt", opts.title, "string", true)
    vim.validate("opts.keymap", opts.keymap, "table", true)
    for i, v in ipairs(opts.keymap or {}) do
        vim.validate("opts.keymap[" .. i .. "]", v, "table")
        vim.validate("opts.keymap[" .. i .. "].lhs", v.lhs, "string")
        vim.validate("opts.keymap[" .. i .. "].rhs", v.rhs, "function")
        vim.validate("opts.keymap[" .. i .. "].desc", v.desc, "string", true)
    end
    vim.validate("opts.map", opts.map, "function", true)

    local orig_options = opts.options
    local update = opts.update or "slow"
    local title = opts.title or "Fuzzy chooser"
    local prompt = opts.prompt or "> "
    local keymap = opts.keymap or {}
    local map = opts.map

    create_windows(title, prompt)

    -- if map function is provided then map all options
    M.choices = {}
    if map then
        for i, option in ipairs(orig_options) do
            M.choices[i] = map(option)
        end
    else
        M.choices = orig_options
    end

    choices_orig = vim.deepcopy(M.choices)

    -- draw initial screen
    M.refresh()

    -- keys to make a <NOP> cause defaults cause issues
    local nop_keys = {
        "<CR>", "<S-CR>",

        -- all mouse buttons can change the mode if spammed
        "<LeftMouse>", "<2-LeftMouse>", "<3-LeftMouse>", "<4-LeftMouse>",
        "<MiddleMouse>", "<2-MiddleMouse>", "<3-MiddleMouse>", "<4-MiddleMouse>",
        "<RightMouse>", "<2-RightMouse>", "<3-RightMouse>", "<4-RightMouse>"
    }
    for _, lhs in ipairs(nop_keys) do
        vim.keymap.set({"n", "i"}, lhs, "<NOP>", { buffer = buf2 })
    end

    -- close on escape
    vim.keymap.set({"n", "i"}, "<Esc>", M.close, { buffer = buf2 })

    -- up/down keys move the upper buffer
    vim.keymap.set("i", "<Up>", function() M.move_cursor_y(-1) end, { buffer = buf2 })
    vim.keymap.set("i", "<Down>", function() M.move_cursor_y(1) end, { buffer = buf2 })

    -- define custom keybindings (can override anything)
    for _, v in ipairs(keymap) do
        vim.keymap.set("i", v.lhs, v.rhs, { buffer = buf2, desc = v.desc or nil })
    end

    -- TODO enable this automatically on smaller lists
    -- TODO fast should use uv.timer_* to reset timer on each character so its
    -- always updated X ms after the last character
    if update == "instant" or update == "fast" then
        -- update on each character
        vim.api.nvim_create_autocmd("TextChangedI", {
            buffer = buf2,
            callback = function() M.refresh(true) end,
        })
    elseif update == "slow" then
        -- TODO potentionally use uv.timer_start so the delay doesnt have to be
        -- tied to timeoutlen and could be just like 50-100ms
        -- update when cursor is idle for timeoutlen (quite long usually)
        vim.api.nvim_create_autocmd("CursorHoldI", {
            buffer = buf2,
            callback = function() M.refresh(true) end,
        })
    else
        -- TODO this should be checked before opening windows..
        error("options.timer = '" .. update .."' is not a valid option")
    end

    -- redraw to show the windows
    vim.cmd("redraw")

    -- start insert mode
    vim.cmd("startinsert")
end

-- TODO show modified flag
-- @param show_if_one should the menu be shown if there is only one buffer
function M.cmd_fuzzy_buffer()
    local sorted_bufs = utils.get_buffers_by_last_used()

    if not sorted_bufs or #sorted_bufs == 0 then
        vim.notify("No buffers found", vim.log.levels.WARN)
        return
    end

    -- just switch if there is only one buffer open
    if #sorted_bufs == 1 then
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

function M.cmd_fuzzy_file(args)
    -- allow specifying the root as argument
    local root
    if args.args and args.args ~= "" then
        root = args.args
    else
        root = nil
    end

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

function M.cmd_fuzzy_map()
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

        -- TODO buffer keys should have a special marker
        -- add buffer keys
        for _, key in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
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

function M.cmd_fuzzy_snippets()
    local lines = {}

    for _, key in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        -- filter the snippets
        if vim.startswith(key.lhs, ",") and vim.endswith(key.lhs, ",") then
            local desc = ""
            if key.desc then
                desc = " - " .. key.desc
            end

            -- remove commas
            table.insert(lines, key.lhs:sub(2):sub(1, -2) .. desc)
        end
    end

    M.fuzzy_chooser {
        title = "Find snippet (fuzzy)",
        options = lines,
        callback = function(index)
            vim.schedule(function()
                -- just run the command, its the simplest way
                vim.cmd("norm ," .. lines[index] .. ",")
            end)
        end,
    }
end

return M
