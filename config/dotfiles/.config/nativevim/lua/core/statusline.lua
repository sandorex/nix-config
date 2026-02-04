local function lsp()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    else
        return "[LSP]"
    end
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function buffer_index()
    local buffers = vim.tbl_filter(function(bufnr)
       return vim.api.nvim_buf_get_option(bufnr, "buflisted")
    end, vim.api.nvim_list_bufs())

    local current_index = indexOf(buffers, vim.api.nvim_get_current_buf())
    if current_index ~= nil then
        return current_index .. "/" .. #buffers
    else
        return "?/" .. #buffers
    end
end

function _G.statusline()
    return table.concat({
        vim.bo.filetype,    -- show filetype (%Y is uppercase)
        "%t",               -- show only the filename
        "%w" ..             -- preview window flag [Preview]
        "%m" ..             -- modified flag [+] / [-]
        "%r" ..             -- readonly flag [RO]
        lsp(),              -- LSP flag [LSP]
        "%=",               -- split statusline
        "%0l:%0c %P",       -- show line:col (progress%)

        -- show index of the current buffer and how many there are (buflisted)
        "(" .. buffer_index() .. ")",
    }, " ")
end

-- run the function and add space to both ends
vim.o.statusline = " %{%v:lua._G.statusline()%} "

