-- very simple implementation of the tabline shamelessly stolen from
-- https://github.com/alvarosevilla95/luatab.nvim/blob/7ac54b014b542f02a73b62fcae65db7a2382a378/lua/luatab/init.lua

local M = {}

M.title = function(bufnr)
    local file = vim.fn.bufname(bufnr)
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local filetype = vim.fn.getbufvar(bufnr, '&filetype')

    if buftype == 'help' then
        return 'help:' .. vim.fn.fnamemodify(file, ':t:r')
    elseif buftype == 'quickfix' then
        return 'quickfix'
    elseif filetype == 'TelescopePrompt' then
        return 'Telescope'
    elseif filetype == 'git' then
        return 'Git'
    elseif filetype == 'fugitive' then
        return 'Fugitive'
    elseif filetype == 'NvimTree' then
        return 'NvimTree'
    elseif filetype == 'neo-tree' then
        return 'NeoTree'
    elseif filetype == 'oil' then
        return 'Oil'
    elseif file:sub(file:len()-2, file:len()) == 'FZF' then
        return 'FZF'
    elseif buftype == 'terminal' then
        local _, mtch = string.match(file, "term:(.*):(%a+)")
        return mtch ~= nil and mtch or vim.fn.fnamemodify(vim.env.SHELL, ':t')
    elseif file == '' then
        return '[No Name]'
    else
        return vim.fn.pathshorten(vim.fn.fnamemodify(file, ':p:~:t'))
    end
end

M.modified = function(bufnr)
    return vim.fn.getbufvar(bufnr, '&modified') == 1 and '[+] ' or ''
end

M.windowCount = function(index)
    local nwins = vim.fn.tabpagewinnr(index, '$')
    return nwins > 1 and '(' .. nwins .. ') ' or ''
end

M.separator = function(index)
    return (index < vim.fn.tabpagenr('$') and '%#TabLine#|' or '')
end

M.cell = function(index)
    local isSelected = vim.fn.tabpagenr() == index
    local buflist = vim.fn.tabpagebuflist(index)
    local winnr = vim.fn.tabpagewinnr(index)
    local bufnr = buflist[winnr]
    local hl = (isSelected and '%#TabLineSel#' or '%#TabLine#')

    return hl .. '%' .. index .. 'T' .. ' ' ..
        M.windowCount(index) ..
        M.title(bufnr) .. ' ' ..
        M.modified(bufnr) .. '%T' ..
        M.separator(index)
end

M.tabline = function()
    local line = ''
    for i = 1, vim.fn.tabpagenr('$'), 1 do
        line = line .. M.cell(i)
    end
    line = line .. '%#TabLineFill#%='
    if vim.fn.tabpagenr('$') > 1 then
        line = line .. '%#TabLine#%999XX'
    end
    return line
end

-- setup
vim.opt.tabline = '%!v:lua.require\'config.tabline\'.tabline()'

return M
