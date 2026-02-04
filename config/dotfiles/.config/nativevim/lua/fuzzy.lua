-- Simple-ish neovim fuzzy searching
--
-- Based on original from Alexis Sellier
-- https://github.com/cloudhead/neovim-fuzzy/blob/16ee769bb459e8173a2ef9f515905c8f879ff7c6/plugin/neovim-fuzzy.vim
--
-- Rewritten in LUA with improvements

-- TODO make it a proper lua module

local M = {}

local fn = vim.fn
local g = vim.g
local executable = vim.fn.executable

if g.fuzzy_opencmd == nil then
    g.fuzzy_opencmd = 'edit'
end

if g.fuzzy_executable == nil then
    g.fuzzy_executable = 'fzy'
end

-- TODO remove it
if g.fuzzy_winheight == nil then
    g.fuzzy_winheight = 12
end

if g.fuzzy_rootcmds == nil then
    g.fuzzy_rootcmds = {
        {"git", "rev-parse", "--show-toplevel"},
        {"hg", "root"}
    }
end

-- TODO should hidden files be included by default?
if g.fuzzy_hidden == nil then
    g.fuzzy_hidden = 0
end

M.fuzzy_job_id = 0
M.fuzzy_prev_window = -1
M.fuzzy_prev_window_height = -1
M.fuzzy_bufnr = -1
M.fuzzy_source = {}
M.fuzzy_selected_opencmd = ''

function M.strip(str)
    return (string.gsub(str, '\n*$', ''))
end

function M.fuzzy_getroot()
    for _, cmd in ipairs(g.fuzzy_rootcmds) do
        if executable(cmd[1]) == 1 then
            local result = fn.system(cmd)
            if vim.v.shell_error == 0 then
                return M.strip(result)
            end
        end
    end

    return "."
end

function M.fuzzy_err_noexec()
    error("Fuzzy: no search executable was found. " ..
    "Please make sure either '" .. M.ag.path ..
    "' or '" .. M.rg.path .. "' are in your path")
end

M.fuzzy_source.find = function(...)
    M.fuzzy_err_noexec()
end
M.fuzzy_source.find_contents = function(...)
    M.fuzzy_err_noexec()
end

-- ag (the silver searcher)
M.ag = { path = 'ag' }
function M.ag.find(self, root)
    local list = { self.path, "--silent", "--nocolor", "-g", "", "-Q" }
    if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
    if root ~= nil and root ~= "" then table.insert(list, root) end
    return fn.systemlist(list)
end
function M.ag.find_contents(self, query)
    if not query or query == "" then query = '^(?=.)' end
    local str = self.path .. (g.fuzzy_hidden == 1 and " --hidden " or " ") .. "--noheading --nogroup --nocolor -S " .. fn.shellescape(query) .. " ."
    return fn.systemlist(str)
end

-- rg (ripgrep)
M.rg = { path = 'rg' }
function M.rg.find(self, root)
    local list = { self.path, "--color", "never", "--files", "--fixed-strings" }
    if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
    if root ~= nil and root ~= "" then table.insert(list, root) end
    return fn.systemlist(list)
end
function M.rg.find_contents(self, query)
    local q = not query or query == "" and '.' or fn.shellescape(query)
    local list = { self.path, "-n", "--no-heading", "--color", "never", "-S", q }
    if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
    return fn.systemlist(list)
end
function M.rg.find_todo(self)
    return fn.systemlist({ self.path, "-n", "--no-heading", "--color", "never", "TODO|FIXME" })
end

function M.fuzzy_kill()
    vim.cmd("echo")
    fn.jobstop(M.fuzzy_job_id)
end

function M.fuzzy_todo()
    local contents

    local ok, err = pcall(function()
        contents = vim.tbl_map(
            function(val)
                return val:gsub("\\s+", " "):gsub('(:[0-9]+:).*()TODO|FIXME', '%1 ')
            end,
            M.fuzzy_source:find_todo()
        )
    end)

    if not ok then
        vim.api.nvim_err_writeln(err)
        return
    end

    -- TODO remove lines and use procentage of the screen like fuzzy
    local opts = { lines = g.fuzzy_winheight, statusfmt = 'FuzzyTodo %s (%d results)', root = '.' }
    opts.handler = function(result)
        local parts = vim.split(table.concat(result), ':')
        local name = parts[1]
        local lnum = parts[2]
        return { name = name, lnum = lnum }
    end
    return M.fuzzy(contents, opts)
end

function M.fuzzy_grep(str)
    local contents

    local ok, err = pcall(function()
        contents = M.fuzzy_source:find_contents(str)
    end)
    if not ok then
        vim.api.nvim_err_writeln(err)
        return
    end

    local opts = { lines = g.fuzzy_winheight, statusfmt = 'FuzzyGrep %s (%d results)', root = '.' }
    opts.handler = function(result)
        local parts = vim.split(table.concat(result), ':')
        local name = parts[1]
        local lnum = parts[2]
        return { name = name, lnum = lnum }
    end

    return M.fuzzy(contents, opts)
end

function M.fuzzy_open(show_bufs, show_files, root)
    if not root or root == '' then
        root = M.fuzzy_getroot()
    end

    vim.cmd('lcd ' .. root)
    local result = {}
    local ignorelist = {}

    if show_bufs == 1 then
        local bufs = {}
        for i = 1, fn.bufnr('$') do
            if fn.buflisted(i) == 1 and fn.bufname(i) ~= "" and i ~= fn.bufnr("#") and i ~= fn.bufnr("%") then
                table.insert(bufs, fn.expand(fn.bufname(i)))
            end
        end

        if fn.bufnr('#') > 0 and fn.bufnr('%') ~= fn.bufnr('#') then
            local altbufname = fn.expand(fn.bufname('#'))
            if altbufname ~= "" and fn.buflisted(fn.bufnr(altbufname)) == 1 then
                table.insert(bufs, 1, altbufname)
            end
        end

        -- Copy to result (guaranteed to be table)
        for _, v in ipairs(bufs) do
            table.insert(result, v)
        end

        if fn.bufname('%') ~= "" then
            for _, v in ipairs(bufs) do
                table.insert(ignorelist, v)
            end

            table.insert(ignorelist, fn.expand(fn.bufname('%')))
        else
            ignorelist = vim.deepcopy(bufs)
        end
    end

    if show_files == 1 then
        local filelist = M.fuzzy_source.find(M.fuzzy_source, root)

        -- filelist can be a string on error, so always make sure it's a table
        if type(filelist) == "string" then
            filelist = vim.split(filelist, "\n", {plain = true, trimempty = true})
        end

        -- Remove empty entries
        local files = {}
        for _, v in ipairs(filelist) do
            if v ~= "" then
                -- Don't add ignored buffers if show_bufs
                if show_bufs == 1 then
                    local skip = false
                    for _, ign in ipairs(ignorelist) do
                        if ign == v then skip = true break end
                    end
                    if not skip then table.insert(files, v) end
                else
                    table.insert(files, v)
                end
            end
        end

        for _, v in ipairs(files) do
            table.insert(result, v)
        end

        vim.cmd('lcd -')
    else
        vim.cmd('lcd -')
    end

    local opts = { lines = g.fuzzy_winheight, statusfmt = 'FuzzyOpen %s (%d files)', root = root }
    opts.handler = function(result)
        return { name = table.concat(result) }
    end
    return M.fuzzy(result, opts)
end

function M.fuzzy(choices, opts)
    local inputs = fn.tempname()
    local outputs = fn.tempname()
    if executable(g.fuzzy_executable) ~= 1 then
        vim.api.nvim_err_writeln("Fuzzy: the executable '" .. g.fuzzy_executable .. "' was not found in your path")
        return
    end

    -- TODO make it almost fullscreen on small terminals and specific size on bigger ones
    -- open a window that is 80% of the screen
    local scale = 0.8
    local popup_width = math.floor(vim.o.columns * scale)
    local popup_height = math.floor(vim.o.lines * scale)
    local popup_row = math.floor((vim.o.lines - popup_height) / 2)
    local popup_col = math.floor((vim.o.columns - popup_width) / 2)

    fn.writefile(choices, inputs)
    local command = g.fuzzy_executable .. " -l " .. popup_height .. " > " .. outputs .. " < " .. inputs

    -- Store previous window/buf
    M.fuzzy_prev_window = vim.api.nvim_get_current_win()
    M.fuzzy_selected_opencmd = ""

    -- TODO the colors in the terminal are not same as regular terminal
    -- Terminal buffer for fuzzy
    local term_buf = vim.api.nvim_create_buf(false, true)
    M.fuzzy_bufnr = term_buf

    -- Open as floating window
    local float_win = vim.api.nvim_open_win(term_buf, true, {
        relative = "editor",
        width = popup_width,
        height = popup_height,
        row = popup_row,
        col = popup_col,
        border = "rounded",
        zindex = 150,
    })
    M.fuzzy_float_win = float_win

    vim.api.nvim_buf_set_option(term_buf, 'filetype', 'fuzzy')
    vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(term_buf, 'swapfile', false)

    local function cleanup_popup()
        if vim.api.nvim_win_is_valid(M.fuzzy_float_win) then
            vim.api.nvim_win_close(M.fuzzy_float_win, true)
        end

        if vim.api.nvim_buf_is_valid(M.fuzzy_bufnr) then
            vim.api.nvim_buf_delete(M.fuzzy_bufnr, { force=true })
        end
    end

    local function open_results(results)
        for _, result in ipairs(results) do
            local file = opts.handler({result})

            vim.cmd('lcd ' .. opts.root)
            if M.fuzzy_selected_opencmd == '' then
                M.fuzzy_selected_opencmd = g.fuzzy_opencmd
            end

            -- Open file in correct window
            vim.cmd('silent ' .. M.fuzzy_selected_opencmd .. ' ' .. fn.fnameescape(fn.expand(file.name)))
            vim.cmd('lcd -')

            if file.lnum then
                vim.cmd('silent ' .. file.lnum)
                vim.cmd('normal! zz')
            end
        end
    end

    local on_exit = function(_, code, _)
        -- First, cleanup the floating popup and switch back to previous window
        cleanup_popup()
        if vim.api.nvim_win_is_valid(M.fuzzy_prev_window) then
            vim.api.nvim_set_current_win(M.fuzzy_prev_window)
        end

        -- Now open results
        if code ~= 0 or fn.filereadable(outputs) == 0 then
            return
        end

        local results = fn.readfile(outputs)
        if #results > 0 then
            open_results(results)
        end
    end

    -- TODO use to jobstart(..., { "term": true }})
    -- Start terminal and job in the scratch buffer
    M.fuzzy_job_id = vim.fn.termopen(command, {on_exit=on_exit, cwd=opts.root})

    -- Status etc
    vim.b.fuzzy_status = string.format(
        opts.statusfmt,
        fn.fnamemodify(opts.root, ':~:.'),
        #choices
    )
    vim.api.nvim_buf_set_option(term_buf, 'modifiable', false)
    vim.api.nvim_set_current_win(float_win)
    vim.cmd('startinsert')
end

function M.fuzzy_split(split)
    local commands = {
        current = 'edit',
        vsplit = 'vsplit',
        split = 'split',
        tab = 'tabe'
    }

    local cmd = commands[split]
    if cmd then
        M.fuzzy_selected_opencmd = cmd
        if fn.exists('*chansend') == 1 then
            fn.chansend(M.fuzzy_job_id, "\r\n")
        else
            fn.jobsend(M.fuzzy_job_id, "\r\n")
        end
    end
end

--- checks if everything needed for plugin is available
function M.available()
    if not M.fuzzy_source then
        return false
    end

    return true
end

--- setup plugin with optional options
function M.setup(opts)
    -- Set the finder based on available binaries.
    if executable(M.rg.path) == 1 then
        M.fuzzy_source = M.rg
    elseif executable(M.ag.path) == 1 then
        M.fuzzy_source = M.ag
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "fuzzy",
        callback = function()
            vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:FuzzyKill<CR>", { desc = "Kill running fuzzy function", silent = true, buffer = true })
            vim.keymap.set("t", "<C-T>", "<C-\\><C-n>:FuzzyOpenFileInTab<CR>", { desc = "Open selected in new tab", silent = true, buffer = true })
            vim.keymap.set("t", "<C-S>", "<C-\\><C-n>:FuzzyOpenFileInSplit<CR>", { desc = "Open selected in new split", silent = true, buffer = true })
            vim.keymap.set("t", "<C-V>", "<C-\\><C-n>:FuzzyOpenFileInVSplit<CR>", { desc = "Open selected in new vertical split", silent = true, buffer = true })
        end,
    })

    vim.api.nvim_create_user_command('FuzzyGrep', function(opts) M.fuzzy_grep(opts.args) end, { nargs = "?" })
    vim.api.nvim_create_user_command('FuzzyFiles', function(opts) M.fuzzy_open(0, 1, opts.args) end, { nargs = "?" })
    vim.api.nvim_create_user_command('FuzzyBuffers', function(opts) M.fuzzy_open(1, 0, opts.args) end, { nargs = "?" })
    vim.api.nvim_create_user_command('FuzzyAll', function(opts) M.fuzzy_open(1, 1, opts.args) end, { nargs = "?" })
    vim.api.nvim_create_user_command('FuzzyTodo', function() M.fuzzy_todo() end, {})

    vim.api.nvim_create_user_command('FuzzyOpenFileInTab', function() M.fuzzy_split('tab') end, {})
    vim.api.nvim_create_user_command('FuzzyOpenFileInSplit', function() M.fuzzy_split('split') end, {})
    vim.api.nvim_create_user_command('FuzzyOpenFileInVSplit', function() M.fuzzy_split('vsplit') end, {})
    vim.api.nvim_create_user_command('FuzzyKill', function() M.fuzzy_kill() end, {})
end

return M
