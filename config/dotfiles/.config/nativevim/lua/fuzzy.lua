-- Simple-ish neovim fuzzy searching
--
-- Based on original from Alexis Sellier
-- https://github.com/cloudhead/neovim-fuzzy/blob/16ee769bb459e8173a2ef9f515905c8f879ff7c6/plugin/neovim-fuzzy.vim
--
-- Rewritten in LUA with improvements

-- TODO make it a proper lua module

local fn = vim.fn
local g = vim.g
local executable = vim.fn.executable

if g.fuzzy_bindkeys == nil then
  g.fuzzy_bindkeys = 1
end

if g.loaded_fuzzy or vim.o.cp or not vim.fn.has("nvim") == 1 then
  return
end

g.loaded_fuzzy = 1

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

if g.fuzzy_hidden == nil then
  g.fuzzy_hidden = 0
end

g.fuzzy_splitcmd_map = {
  current = 'edit',
  vsplit = 'vsplit',
  split = 'split',
  tab = 'tabe'
}

if g.fuzzy_bindkeys == 1 then
  vim.cmd([[
    autocmd FileType fuzzy tnoremap <silent> <buffer> <Esc> <C-\><C-n>:FuzzyKill<CR>
    autocmd FileType fuzzy tnoremap <silent> <buffer> <C-T> <C-\><C-n>:FuzzyOpenFileInTab<CR>
    autocmd FileType fuzzy tnoremap <silent> <buffer> <C-S> <C-\><C-n>:FuzzyOpenFileInSplit<CR>
    autocmd FileType fuzzy tnoremap <silent> <buffer> <C-V> <C-\><C-n>:FuzzyOpenFileInVSplit<CR>
  ]])
end

local s = {}
s.fuzzy_job_id = 0
s.fuzzy_prev_window = -1
s.fuzzy_prev_window_height = -1
s.fuzzy_bufnr = -1
s.fuzzy_source = {}
s.fuzzy_selected_opencmd = ''

local function strip(str)
  return (string.gsub(str, '\n*$', ''))
end

function s.fuzzy_getroot()
  for _, cmd in ipairs(g.fuzzy_rootcmds) do
    if executable(cmd[1]) == 1 then
      local result = fn.system(cmd)
      if vim.v.shell_error == 0 then
        return strip(result)
      end
    end
  end
  return "."
end

function s.fuzzy_err_noexec()
  error("Fuzzy: no search executable was found. " ..
      "Please make sure either '" .. s.ag.path ..
      "' or '" .. s.rg.path .. "' are in your path")
end

s.fuzzy_source.find = function(...)
  s.fuzzy_err_noexec()
end
s.fuzzy_source.find_contents = function(...)
  s.fuzzy_err_noexec()
end

-- ag (the silver searcher)
s.ag = { path = 'ag' }
function s.ag.find(self, root)
  local list = { self.path, "--silent", "--nocolor", "-g", "", "-Q" }
  if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
  if root ~= nil and root ~= "" then table.insert(list, root) end
  return fn.systemlist(list)
end
function s.ag.find_contents(self, query)
  if not query or query == "" then query = '^(?=.)' end
  local str = self.path .. (g.fuzzy_hidden == 1 and " --hidden " or " ") .. "--noheading --nogroup --nocolor -S " .. fn.shellescape(query) .. " ."
  return fn.systemlist(str)
end

-- rg (ripgrep)
s.rg = { path = 'rg' }
function s.rg.find(self, root)
  local list = { self.path, "--color", "never", "--files", "--fixed-strings" }
  if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
  if root ~= nil and root ~= "" then table.insert(list, root) end
  return fn.systemlist(list)
end
function s.rg.find_contents(self, query)
  local q = not query or query == "" and '.' or fn.shellescape(query)
  local list = { self.path, "-n", "--no-heading", "--color", "never", "-S", q }
  if g.fuzzy_hidden == 1 then table.insert(list, "--hidden") end
  return fn.systemlist(list)
end
function s.rg.find_todo(self)
  return fn.systemlist({ self.path, "-n", "--no-heading", "--color", "never", "TODO|FIXME" })
end

-- find + grep
s.find = { path = 'find' }
function s.find.find(self, root)
  root = root or '.'
  local cmd = { self.path, root, "-type", "f" }
  return fn.systemlist(cmd)
end
function s.find.find_contents(self, query)
  if not query or query == "" then
    query = '.'
  end

  local cmd = { "grep", "-rn", query, "." }

  return fn.systemlist(cmd)
end

-- Set the finder based on available binaries.
if executable(s.rg.path) == 1 then
  s.fuzzy_source = s.rg
elseif executable(s.ag.path) == 1 then
  s.fuzzy_source = s.ag
else
  s.fuzzy_source = s.find
end

vim.api.nvim_create_user_command('FuzzyGrep', function(opts) s.fuzzy_grep(opts.args) end, { nargs = "?" })
vim.api.nvim_create_user_command('FuzzyFiles', function(opts) s.fuzzy_open(0, 1, opts.args) end, { nargs = "?" })
vim.api.nvim_create_user_command('FuzzyBuffers', function(opts) s.fuzzy_open(1, 0, opts.args) end, { nargs = "?" })
vim.api.nvim_create_user_command('FuzzyAll', function(opts) s.fuzzy_open(1, 1, opts.args) end, { nargs = "?" })
vim.api.nvim_create_user_command('FuzzyOpenFileInTab', function() s.fuzzy_split('tab') end, {})
vim.api.nvim_create_user_command('FuzzyOpenFileInSplit', function() s.fuzzy_split('split') end, {})
vim.api.nvim_create_user_command('FuzzyOpenFileInVSplit', function() s.fuzzy_split('vsplit') end, {})
vim.api.nvim_create_user_command('FuzzyTodo', function() s.fuzzy_todo() end, {})
vim.api.nvim_create_user_command('FuzzyKill', function() s.fuzzy_kill() end, {})

function s.fuzzy_kill()
  vim.cmd("echo")
  fn.jobstop(s.fuzzy_job_id)
end

function s.fuzzy_todo()
  local contents

  local ok, err = pcall(function()
    contents = vim.tbl_map(
        function(val)
          return val:gsub("\\s+", " "):gsub('(:[0-9]+:).*()TODO|FIXME', '%1 ')
        end,
        s.fuzzy_source:find_todo()
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
  return s.fuzzy(contents, opts)
end

function s.fuzzy_grep(str)
  local contents
  local ok, err = pcall(function()
    contents = s.fuzzy_source:find_contents(str)
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
  return s.fuzzy(contents, opts)
end

function s.fuzzy_open(show_bufs, show_files, root)
  if not root or root == '' then
    root = s.fuzzy_getroot()
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
    for _, v in ipairs(bufs) do table.insert(result, v) end
    if fn.bufname('%') ~= "" then
      for _, v in ipairs(bufs) do table.insert(ignorelist, v) end
      table.insert(ignorelist, fn.expand(fn.bufname('%')))
    else
      ignorelist = vim.deepcopy(bufs)
    end
  end

  if show_files == 1 then
    local filelist = s.fuzzy_source.find(s.fuzzy_source, root)
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
    -- Extend result
    for _, v in ipairs(files) do table.insert(result, v) end
    vim.cmd('lcd -')
  else
    vim.cmd('lcd -')
  end

  local opts = { lines = g.fuzzy_winheight, statusfmt = 'FuzzyOpen %s (%d files)', root = root }
  opts.handler = function(result)
    return { name = table.concat(result) }
  end
  return s.fuzzy(result, opts)
end

function s.fuzzy(choices, opts)
  local inputs = fn.tempname()
  local outputs = fn.tempname()
  if executable(g.fuzzy_executable) ~= 1 then
    vim.api.nvim_err_writeln("Fuzzy: the executable '" .. g.fuzzy_executable .. "' was not found in your path")
    return
  end

  -- open a window that is 80% of the screen
  local scale = 0.8
  local popup_width = math.floor(vim.o.columns * scale)
  local popup_height = math.floor(vim.o.lines * scale)
  local popup_row = math.floor((vim.o.lines - popup_height) / 2)
  local popup_col = math.floor((vim.o.columns - popup_width) / 2)

  fn.writefile(choices, inputs)
  local command = g.fuzzy_executable .. " -l " .. popup_height .. " > " .. outputs .. " < " .. inputs

  -- Store previous window/buf
  s.fuzzy_prev_window = vim.api.nvim_get_current_win()
  s.fuzzy_selected_opencmd = ""

  -- TODO the colors in the terminal are not same as regular terminal
  -- Terminal buffer for fuzzy
  local term_buf = vim.api.nvim_create_buf(false, true)
  s.fuzzy_bufnr = term_buf

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
  s.fuzzy_float_win = float_win

  vim.api.nvim_buf_set_option(term_buf, 'filetype', 'fuzzy')
  vim.api.nvim_buf_set_option(term_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(term_buf, 'swapfile', false)

  local function cleanup_popup()
    if vim.api.nvim_win_is_valid(s.fuzzy_float_win) then
      vim.api.nvim_win_close(s.fuzzy_float_win, true)
    end

    if vim.api.nvim_buf_is_valid(s.fuzzy_bufnr) then
      vim.api.nvim_buf_delete(s.fuzzy_bufnr, { force=true })
    end
  end

  local function open_results(results)
    for _, result in ipairs(results) do
      local file = opts.handler({result})
      vim.cmd('lcd ' .. opts.root)
      if s.fuzzy_selected_opencmd == '' then
        s.fuzzy_selected_opencmd = g.fuzzy_opencmd
      end
      -- Open file in correct window
      vim.cmd('silent ' .. s.fuzzy_selected_opencmd .. ' ' .. fn.fnameescape(fn.expand(file.name)))
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
    if vim.api.nvim_win_is_valid(s.fuzzy_prev_window) then
      vim.api.nvim_set_current_win(s.fuzzy_prev_window)
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
  s.fuzzy_job_id = vim.fn.termopen(command, {on_exit=on_exit, cwd=opts.root})

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

function s.fuzzy_split(split)
  local cmd = g.fuzzy_splitcmd_map[split]
  if cmd then
    s.fuzzy_selected_opencmd = cmd
    if fn.exists('*chansend') == 1 then
      fn.chansend(s.fuzzy_job_id, "\r\n")
    else
      fn.jobsend(s.fuzzy_job_id, "\r\n")
    end
  end
end
