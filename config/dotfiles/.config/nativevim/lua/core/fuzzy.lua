local TIMEOUTLEN = vim.g.fuzzy_timeoutlen or 250

-- threshold when to use instant update when fuzzy finding
local INSTANT_ELEM_THRESHOLD = 5000

local ns = vim.api.nvim_create_namespace("core_fuzzy")
local choices = {}
local last_query = ""
local timer = nil

local win1 = nil
local buf1 = nil
local win2 = nil
local buf2 = nil

local M = {}

local function stop_timer()
    if timer then
        timer:stop()

        -- proper cleanup
        if not timer:is_closing() then
            timer:close()
        end
    end
end

local function reset_timer()
    stop_timer()

    -- restart timer
    timer = vim.defer_fn(function()
        M.refresh(true)
    end, TIMEOUTLEN)
end

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
    choices = {}

    stop_timer()
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

    -- do not compute if the query is the same and is lazy
    if query == last_query and lazy == true then
        return
    end

    -- update last query
    last_query = query

    -- do the fuzzy
    local sorted = {}
    if query ~= nil and query ~= "" then
        -- TODO try matchfuzzypos maybe i wouldnt need to iterate so much to find selected etc
        sorted = vim.fn.matchfuzzy(choices, query, { key = "value" })
    else
        sorted = choices
    end

    -- convert the hashmap to text for the buffer
    local text = {}
    for _, i in ipairs(sorted) do
        table.insert(text, i.display or i.value)
    end

    -- write text to the buffer
    vim.api.nvim_buf_set_lines(buf1, 0, -1, false, text)

    -- reset selection as they things might have changed
    vim.api.nvim_win_set_cursor(win1, { 1, 0 })
end

--- Get index of selected item
function M.get_selected_index()
    local cursor_y = vim.api.nvim_win_get_cursor(win1)[1]
    local line = vim.api.nvim_buf_get_lines(buf1, cursor_y - 1, cursor_y, false)[1]

    -- find the choice using line in buffer
    for _, i in ipairs(choices) do
        if (i.display and i.display == line) or i.value == line then
            return i.index
        end
    end

    return nil
end

--- Get index of selected item after mouse press
function M.get_mouse_selected_index()
    local mousepos = vim.fn.getmousepos()
    if mousepos.winid == win1 and mousepos.line >= 1 then
        local line = vim.api.nvim_buf_get_lines(buf1, mousepos.line - 1, mousepos.line, false)[1]

        -- find the choice using line in buffer
        for _, i in ipairs(choices) do
            if (i.display and i.display == line) or i.value == line then
                return i.index
            end
        end
    end

    return nil
end

--- Remove entry from choices (remember to refresh afterwards!)
function M.remove_entry(index)
    for i, c in ipairs(choices) do
        if c.index == index then
            table.remove(choices, i)
            return
        end
    end
end

function M.open(options)
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
    local update = opts.update or "fast"
    local title = opts.title or "Fuzzy"
    local prompt = opts.prompt or "> "
    local keymap = opts.keymap or {}
    local map = opts.map

    create_windows(title, prompt)

    -- if map function is provided then map all options
    choices = {}
    if map then
        for i, option in ipairs(orig_options) do
            -- TODO this will fail if the map does not return two values
            local value, display = map(option)
            table.insert(choices, { index = i, value = value, display = display })
        end
    else
        for i, option in ipairs(orig_options) do
            table.insert(choices, { index = i, value = option, display = nil })
        end
    end

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

    -- use instant if there are few options
    if update == "instant" or (update == "fast" and #orig_options < INSTANT_ELEM_THRESHOLD) then
        -- update on each character
        vim.api.nvim_create_autocmd("TextChangedI", {
            buffer = buf2,
            callback = function() M.refresh(true) end,
        })
    elseif update == "fast" then
        -- uses a timer to update TIMEOUTLEN millis after last character change
        vim.api.nvim_create_autocmd("TextChangedI", {
            buffer = buf2,
            callback = reset_timer,
        })
    elseif update == "slow" then
        -- update when cursor is idle for timeoutlen (quite long usually)
        vim.api.nvim_create_autocmd("CursorHoldI", {
            buffer = buf2,
            callback = function() M.refresh(true) end,
        })
    else
        -- TODO this should be checked before opening windows..
        error("options.timer = '" .. update .."' is not a valid option")
        M.close()
    end

    -- redraw to show the windows
    vim.cmd("redraw!")

    -- start insert mode
    vim.cmd("startinsert")
end

return M
