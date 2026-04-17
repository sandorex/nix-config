-- defines all fuzzy commands

local const = require("core.constants")
local utils = require("core.utils")
local fuzzy = require("core.fuzzy")
local M = {}

function M.fuzzy_buffer()
    local sorted_bufs = utils.get_buffers_by_last_used()

    if not sorted_bufs or #sorted_bufs == 0 then
        vim.notify("No buffers found", vim.log.levels.WARN)
        return
    end

    local function switch(index)
        if index == nil then
            return
        end

        fuzzy.close()

        -- change buffer
        vim.cmd("buffer " .. sorted_bufs[index].buf)
    end

    local function delete(index)
        if index == nil then
            return
        end

        -- remove specified item
        fuzzy.remove_entry(index)
        vim.cmd("bdelete " .. sorted_bufs[index].buf)

        -- refresh list
        fuzzy.refresh()
    end

    fuzzy.open {
        title = "Select buffer (fuzzy)",
        update = "instant", -- there will never be too many buffers
        options = sorted_bufs,
        map = function(buf)
            local name
            if vim.startswith(buf.name, "/") then
                -- shorten the filename if in home or CWD
                name = vim.fn.fnamemodify(buf.name, ':~:.')
            else
                name = buf.name
            end

            -- show if buffer is modified and unsaved
            return name, name .. (buf.changed == 1 and " [+]" or "")
        end,
        keymap = {
            { lhs = "<CR>", rhs = function() switch(fuzzy.get_selected_index()) end },
            { lhs = "<M-d>", rhs = function() delete(fuzzy.get_selected_index()) end },
            { lhs = "<LeftMouse>", rhs = function() switch(fuzzy.get_mouse_selected_index()) end },
            { lhs = "<MiddleMouse>", rhs = function() delete(fuzzy.get_mouse_selected_index()) end },
        },
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
-- if vim.fn.executable("rg") == 1 then
--     find_files = find_files_rg
-- else
--  NOTE: i am testing the pure lua version at the moment
    find_files = require("core.find").find_files
-- end

function M.fuzzy_file(args)
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

    local function select(index)
        if index then
            -- close fuzzy first
            fuzzy.close()

            vim.cmd("edit " .. files[index])
        end
    end

    fuzzy.open {
        title = "Select file (fuzzy)",
        options = files,
        map = function(file)
            if vim.startswith(file, "/") then
                return vim.fn.fnamemodify(file, ':~:.'), nil
            else
                return file, nil
            end
        end,
        keymap = {
            { lhs = "<CR>", rhs = function() select(fuzzy.get_selected_index()) end },
            { lhs = "<LeftMouse>", rhs = function() select(fuzzy.get_mouse_selected_index()) end },
        },
    }
end

-- TODO can you find information where binding was defined somehow? with :verbose map?
-- TODO limit the length of rhs (it hides description)
function M.fuzzy_key()
    local lines = {}

    local function add_key(key, buffer)
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
            "%s %-3s '%s'%s%s",
            (buffer and "B") or " ", -- flag buffer-only binding
            key.mode,
            key.lhs,
            rhs,
            desc
        ))
    end

    -- add keys for all the modes
    for _, mode in ipairs({ "n", "i", "l", "v", "s", "x", "o", "c", "t" }) do
        -- add buffer keys
        for _, key in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
            add_key(key, true)
        end

        for _, key in ipairs(vim.api.nvim_get_keymap(mode)) do
            add_key(key, false)
        end
    end

    fuzzy.open {
        title = "Find key (fuzzy)",
        options = lines,
        keymap = {
            { lhs = "<CR>", rhs = fuzzy.close },
            { lhs = "<LeftMouse>", rhs = fuzzy.close },
        },
    }
end

function M.fuzzy_snippets()
    local lines = {}

    for _, key in ipairs(vim.api.nvim_buf_get_keymap(0, "n")) do
        -- filter the snippets
        if vim.startswith(key.lhs, const.snippet_key) and vim.endswith(key.lhs, const.snippet_key) then
            local desc = ""
            if key.desc then
                desc = " - " .. key.desc
            end

            -- remove commas
            table.insert(lines, key.lhs:sub(2):sub(1, -2) .. desc)
        end
    end

    local function select(index)
        if index then
            -- close the fuzzy first so its doesnt run in wrong buffer
            fuzzy.close()

            -- just run the command, its the simplest way
            vim.cmd("normal " .. const.snippet_key .. lines[index] .. const.snippet_key)
        end
    end

    fuzzy.open {
        title = "Select snippet (fuzzy)",
        options = lines,
        keymap = {
            { lhs = "<CR>", rhs = function() select(fuzzy.get_selected_index()) end },
            { lhs = "<LeftMouse>", rhs = function() select(fuzzy.get_mouse_selected_index()) end },
        },
    }
end

local cmd = vim.api.nvim_create_user_command

cmd("FuzzyBuffer", M.fuzzy_buffer, { desc = "Switch to buffer (fuzzy)" })
cmd("FuzzyFile", M.fuzzy_file, { desc = "Edit file (fuzzy)", nargs="?" })
cmd("FuzzyKey", M.fuzzy_key, { desc = "Search keys (fuzzy)" })
cmd("FuzzySnippet", M.fuzzy_snippets, { desc = "Search snippets (fuzzy)" })

return M
