-- shortened mode strings
local mode_strings = {
    ["n"]  = "NORMAL",
    ["v"]  = "VISUAL",
    ["V"]  = "V LINE",
    [""] = "V BLOCK",
    ["s"]  = "SELECT",
    ["S"]  = "L SELECT",
    [""] = "S BLOCK",
    ["i"]  = "INSERT",
    ["R"]  = "REPLACE",
    ["Rv"] = "V REPLACE",
    ["cr"] = "REPLACE",
    ["c"]  = "COMMAND",
    ["r"]  = "PROMPT",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"]  = "SHELL",
    ["t"]  = "TERMINAL",
}

-- contains hightlighting for each mode
local mode_hl = {
    ["n"]  = "%#StatuslineNormalAccent#",
    ["v"]  = "%#StatuslineVisualAccent#",
    ["V"]  = "%#StatuslineVisualAccent#",
    [""] = "%#StatuslineVisualAccent#",
    ["i"]  = "%#StatuslineInsertAccent#",
    ["R"]  = "%#StatuslineReplaceAccent#",
    ["c"]  = "%#StatuslineCommandAccent#",
    ["t"]  = "%#StatuslineTerminalAccent#",
}

-- fallback color
vim.api.nvim_set_hl(0, 'StatusLineAccent', {
    fg = "#82AAFF",
    bg = "#1E2030",
    bold = true,
})

vim.api.nvim_set_hl(0, 'StatusLineNormalAccent', {
    fg = "#1E2030",
    bg = "#82AAFF",
    bold = true,
})

vim.api.nvim_set_hl(0, 'StatusLineInsertAccent', {
    fg = "#1E2030",
    bg = "#98F096",
    bold = true
})

vim.api.nvim_set_hl(0, 'StatusLineVisualAccent', {
    fg = "#1E2030",
    bg = "#B767EB",
    bold = true
})

vim.api.nvim_set_hl(0, 'StatusLineReplaceAccent', {
    fg = "#1E2030",
    bg = "#FF5656",
    bold = true
})

vim.api.nvim_set_hl(0, 'StatusLineCommandAccent', {
    fg = "#1E2030",
    bg = "#F0A17A",
    bold = true
})

vim.api.nvim_set_hl(0, 'StatusLineTerminalAccent', {
    fg = "#1E2030",
    bg = "#D5E1FB",
    bold = true
})

local function mode()
    -- use first two characters only
    local curr = vim.api.nvim_get_mode().mode:sub(1, 2)

    -- fallback to single character
    local mode_string = mode_strings[curr] or (mode_strings[curr:sub(1, 1)] or "?")
    local mode_color = mode_hl[curr] or (mode_hl[curr:sub(1, 1)] or "%#StatusLineAccent#")

    return mode_color .. " " .. mode_string .. " %*"
end

local function filename()
    local path = vim.api.nvim_buf_get_name(0)
    if not path or path == "" then
        -- use neovim default for invalid names
        return "%t"
    end

    return vim.fn.fnamemodify(path, ':~:.')
end

local function filetype()
    return "%#Type#"        -- highlight filetype
        .. vim.bo.filetype
        .. "%*"
end

local function lsp()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return ""
    else
        return "[LSP]"
    end
end

local function diagnostics()
    local counts = vim.diagnostic.count(0)

    -- if no diagnostics show LSP flag if running
    if vim.tbl_isempty(counts) then
        return lsp()
    end

    local severity_map = {
        { id = vim.diagnostic.severity.ERROR, label = "E", hl = "DiagnosticSignError" },
        { id = vim.diagnostic.severity.WARN,  label = "W", hl = "DiagnosticSignWarn" },
        { id = vim.diagnostic.severity.INFO,  label = "I", hl = "DiagnosticSignInfo" },
        { id = vim.diagnostic.severity.HINT,  label = "H", hl = "DiagnosticSignHint" },
    }

    local parts = {}
    for _, item in ipairs(severity_map) do
        local count = counts[item.id] or 0
        if count > 0 then
            table.insert(parts, "%#" .. item.hl .. "#" .. item.label .. count .. "%*")
        end
    end

    return "[" .. table.concat(parts, " ") .. "]"
end

local function progress()
    -- vim.ui.progress_status is 0.12 only
    local ok, val = pcall(vim.ui.progress_status)
    if ok and val ~= "" then
        return "[" .. val .. "] "
    end

    return ""
end

function _G.my_statusline()
    return table.concat({
        mode(),
        filetype(),
        "%(" ..
        "w" ..              -- preview window flag [Preview]
        "%m" ..             -- modified flag [+] / [-]
        "%r" ..             -- readonly flag [RO]
        diagnostics() ..    -- show [LSP] or [E2 W3 I1 H3]
        " %)" ..            -- group so if empty no whitespace is left
        "%<" ..             -- truncate at filename
        filename(),         -- filename but with minimized path
        "%=",               -- split statusline
        -- progress() ..    -- show progress (WIP)
        "%0l:%0c %P ",      -- show line:col progress%
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.my_statusline()%}"

