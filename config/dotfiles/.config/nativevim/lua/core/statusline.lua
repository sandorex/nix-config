local function lsp()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    else
        return "[LSP]"
    end
end

function _G.statusline()
    return table.concat({
        "%Y",           -- show filetype
        "%t",           -- show only the filename
        "%w" ..         -- preview window flag [Preview]
        "%m" ..         -- modified flag [+] / [-]
        "%r" ..         -- readonly flag [RO]
        lsp(),          -- LSP flag [LSP]
        "%=",           -- split statusline
        "%0l:%0c (%P)", -- show line:col (progress%)
    }, " ")
end

-- run the function and add space to both ends
vim.o.statusline = " %{%v:lua._G.statusline()%} "

