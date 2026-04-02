-- shortened mode strings
local mode_strings = {
    ["n"]  = "N",
    ["no"] = "N",
    ["v"]  = "V",
    ["V"]  = "VL",
    [""] = "VB",
    ["s"]  = "S",
    ["S"]  = "SL",
    [""] = "SB",
    ["i"]  = "I",
    ["ic"] = "I",
    ["R"]  = "R",
    ["Rv"] = "VR",
    ["c"]  = "C",
    ["cv"] = "VE",
    ["ce"] = "EX",
    ["r"]  = "P",
    ["rm"] = "MO",
    ["r?"] = "CO",
    ["!"]  = "SH",
    ["t"]  = "T",
}

-- contains hightlighting for each mode
local mode_hl = {
    ["v"]  = "%#StatuslineVisualAccent#",
    ["V"]  = "%#StatuslineVisualAccent#",
    [""] = "%#StatuslineVisualAccent#",
    ["i"]  = "%#StatuslineInsertAccent#",
    ["ic"] = "%#StatuslineInsertAccent#",
    ["R"]  = "%#StatuslineReplaceAccent#",
    ["Rv"] = "%#StatuslineReplaceAccent#",
    ["c"]  = "%#StatuslineCmdLineAccent#",
    ["t"]  = "%#StatuslineTerminalAccent#",
}

local function lsp()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    else
        return "[LSP]"
    end
end

-- TODO do the rest of accents
vim.api.nvim_set_hl(0, 'StatusLineAccent', {
    fg = "#FFFFFF",
    bg = "#393D5C",
    -- bold = true
})

local function mode()
    local current_mode = vim.api.nvim_get_mode().mode
    local mode_string = mode_strings[current_mode] or "?"
    local mode_color = mode_hl[current_mode] or "%#StatusLineAccent#"

    -- NOTE padding here is so that rest of statusline does not move when
    -- changing between different length mode strings
    local padding = (mode_string:len() == 1 and " ") or ""
    return mode_color .. " " .. mode_string .. " %*" .. padding
end

local function filename()
    local path = vim.api.nvim_buf_get_name(0)
    if not path or path == "" then
        return "%t"
    end

    return vim.fn.fnamemodify(path, ':~:.')
end

local function filetype()
    return "%#Type#"        -- highlight filetype
        .. vim.bo.filetype
        .. "%*"
end

-- TODO there are extra spaces when no flags are present!
function _G.statusline()
    return table.concat({
        mode(),
        filetype(),
        "%w" ..             -- preview window flag [Preview]
        "%m" ..             -- modified flag [+] / [-]
        "%r" ..             -- readonly flag [RO]
        lsp() ..            -- LSP flag [LSP]
        " %<" ..            -- truncate at filename
        filename(),         -- filename but with minimized path
        "%=",               -- split statusline
        "%0l:%0c %P ",      -- show line:col progress%
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"

