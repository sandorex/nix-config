local utils = require("core.extras.utils")
local fzy = {}

local SCORE_GAP_LEADING = -0.005
local SCORE_GAP_TRAILING = -0.005
local SCORE_GAP_INNER = -0.01
local SCORE_MATCH_CONSECUTIVE = 1.0
local SCORE_MATCH_SLASH = 0.9
local SCORE_MATCH_WORD = 0.8
local SCORE_MATCH_CAPITAL = 0.7
local SCORE_MATCH_DOT = 0.6
local SCORE_MIN = -math.huge
local SCORE_MAX = math.huge

local function compute_bonus(str)
    local n = #str
    local bonuses = {}
    local last_char = "/"

    for i = 1, n do
        local char = str:sub(i, i)
        local score = 0

        if last_char == "/" then score = SCORE_MATCH_SLASH
        elseif last_char == "-" or last_char == "_" or last_char == " " then score = SCORE_MATCH_WORD
        elseif last_char == "." then score = SCORE_MATCH_DOT
        elseif last_char:match("%l") and char:match("%u") then score = SCORE_MATCH_CAPITAL
        end

        bonuses[i] = score
        last_char = char
    end
    return bonuses
end

local function score_item(needle, haystack)
    local n = #needle
    local m = #haystack

    if n == 0 or m == 0 or n > m then return SCORE_MIN end
    if n == m then return SCORE_MAX end

    local bonus = compute_bonus(haystack)
    local D = {}
    local M = {}

    for i = 1, n do
        D[i] = {}
        M[i] = {}
    end

    for i = 1, n do
        local prev_score = SCORE_MIN
        local gap_score = (i == n) and SCORE_GAP_TRAILING or SCORE_GAP_INNER
        local needle_char = needle:sub(i, i):lower()

        for j = 1, m do
            local haystack_char = haystack:sub(j, j):lower()

            if needle_char == haystack_char then
                local score = SCORE_MIN
                if i == 1 then
                    score = (j - 1) * SCORE_GAP_LEADING + bonus[j]
                elseif j > 1 then
                    score = math.max(
                        M[i - 1][j - 1] + bonus[j],
                        D[i - 1][j - 1] + SCORE_MATCH_CONSECUTIVE
                    )
                end
                D[i][j] = score
                M[i][j] = math.max(score, prev_score + gap_score)
                prev_score = M[i][j]
            else
                D[i][j] = SCORE_MIN
                M[i][j] = prev_score + gap_score
                prev_score = M[i][j]
            end
        end
    end

    return M[n][m]
end

function fzy.fuzzy_search(needle, haystack_list)
    local results = {}
    for _, item in ipairs(haystack_list) do
        local score = score_item(needle, item)
        if score > SCORE_MIN then
            table.insert(results, { value = item, score = score })
        end
    end

    table.sort(results, function(a, b) return a.score > b.score end)
    return results
end

function fzy.fuzzy_chooser(title, options, format_callback, callback)
    local buf = vim.api.nvim_create_buf(false, true)
    local ui = vim.api.nvim_list_uis()[1]

    -- special prompt buffer
    vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
    vim.fn.prompt_setprompt(buf, "> ")

    -- responsive size
    local width = math.min(80, ui.width)
    local height = math.min(80, ui.height - 4)

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

    local lines = {}
    for i, item in ipairs(options) do
        lines[i] = format_callback(item)
    end

    local function render(query)
        local formatted = {}
        if query ~= nil and query ~= "" then
            for i, val in ipairs(fzy.fuzzy_search(query, lines)) do
                formatted[i] = val.value
            end
        else
            formatted = lines
        end

        -- write text to the buffer
        vim.api.nvim_buf_set_lines(buf, 0, -2, false, formatted)

        -- return first line
        return formatted[1]
    end

    local win = vim.api.nvim_open_win(buf, true, opts)

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.fn.prompt_setcallback(buf, function(text)
        -- render again and get the first line
        local target = render(text)

        -- find the option
        local index = utils.tbl_find(target, lines)
        if index ~= nil then
            callback(options[index])
        else
            error("The first line is not valid option")
        end

        -- close the window now
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

    fzy.fuzzy_chooser(
        "Select buffer (fuzzy)",
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
                print("FuzzyBuffer cancelled")
            end
        end
    )
end

vim.api.nvim_create_user_command("FuzzyBuffer", function() fuzzy_buffer(false) end, { desc = "Choose buffer (fuzzy)" })

return fzy
