-- all keybindings should be here

local utils = require("core.utils")
local const = require("core.constants")

if vim.fn.has("nvim-0.12") == 1 then
    vim.cmd("packadd! nvim.undotree")
end

-- make wildchar trigger autocompletion in command mode (<tab> by default)
vim.o.wildcharm = vim.o.wildchar

local map = vim.keymap.set

local function deprecated(msg)
    return function()
        vim.notify("Key deprecated: " .. msg, vim.log.levels.WARN)
    end
end

-------------------------------------------------------------------------------
-- Movement keybindings                                                      --
-------------------------------------------------------------------------------
-- window focus movement
map('n', '<C-Left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-Right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-Down>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-Up>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-------------------------------------------------------------------------------
-- Quality of life additions                                                 --
-------------------------------------------------------------------------------
map("n", "<leader>f", "<cmd>e %:p:h<cr>", { desc = "Open netrw current buffer directory" })
map("n", "<leader>F", "<cmd>e .<cr>", { desc = "Open netrw in CWD" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", deprecated("Use <c-w>c to close window or ZZ to close/quit"))

map("n", "<leader>u", function() require("undotree").open() end, { desc = "Open undotree plugin" })
map("n", "<s-u>", "<cmd>redo<cr>", { desc = "Redo" })

-- with single snippet key show fuzzy picker
map("n", const.snippet_key, "<cmd>FuzzySnippet<cr>", { desc = "Select snippet (fuzzy)" })

-- easy system clipboard copy / paste by prefixing with <leader>
map({"n", "v"}, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>Y", '"+yg_', { desc = "Copy line to system clipboard" })

map({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({"n", "v"}, "<leader>P", '"+P', { desc = "Paste from system clipboard" })

-- buffer stuff
map("n", "<leader>b", "<cmd>FuzzyBuffer<cr>", { desc = "Choose buffer" })
map("n", "<C-b>", "<cmd>FuzzyBuffer<cr>", { desc = "Choose buffer" })
-- map("n", "<leader>b", ":ls<cr>:b<space>", { desc = "Macro to list buffers" })
map("n", "<M-b>", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })

-- tab stuff
-- imitate ]b [b for switching buffers
map("n", "]t", "<cmd>tabnext<cr>", { desc = "Goto next tab" })
map("n", "[t", "<cmd>tabprevious<cr>", { desc = "Goto previous tab" })

-- make <Up>/<Down> respect word wrap but not when count is used
map("i", "<Up>", "v:count == 0 ? '<C-o>gk' : '<C-o>k'", { expr = true, silent = true })
map("i", "<Down>", "v:count == 0 ? '<C-o>gj' : '<C-o>j'", { expr = true, silent = true })
map({"n", "v"}, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({"n", "v"}, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move content lines
map('n', '<M-Up>', '<cmd>m .-2<cr>==', { desc = 'Move line up', silent = true })
map('n', '<M-Down>', '<cmd>m .+1<cr>==', { desc = 'Move line down', silent = true })
map('v', '<M-Up>', ":m '<-2<cr>gv=gv", { desc = 'Move lines up', silent = true })
map('v', '<M-Down>', ":m '>+1<cr>gv=gv", { desc = 'move lines down', silent = true })

-- TODO does not work with block selection
local pairs = {
    ["<"] = ">",
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
}
map("v", '<M-s>', function()
    if vim.fn.mode() == "" then
        vim.notify("Surround does not yet support visual block mode", vim.log.levels.ERROR)
        return
    end

    local count = vim.v.count1
    local ch = vim.fn.nr2char(vim.fn.getchar(-1))
    local ch2 = pairs[ch] or ch

    -- replace selection
    vim.cmd("normal! c")

    -- paste while repeating character pressed
    vim.api.nvim_paste(string.rep(ch, count) .. vim.fn.getreg('"') .. string.rep(ch2, count), false, -1)
end, { desc = "Surround selection" })

-- terminal
map("t", "<c-\\><c-\\>", "<c-\\><c-n>", { desc = "Exit terminal insert mode" })

-- creates a function that just goes to the buffer indexed by last usage
local function goto_buff(index)
    return function()
        local buffers = utils.get_buffers_by_last_used()
        if #buffers <= 0 or #buffers < index then
            vim.notify("Buffer index " .. index .. " out of range", vim.log.levels.WARN)
        else
            vim.cmd("buffer " .. buffers[index].buf)
        end
    end
end

map("n", "<M-1>", goto_buff(1), { desc = "Goto last used buffer" })
map("n", "<M-2>", goto_buff(2), { desc = "Goto second last used buffer" })
map("n", "<M-3>", goto_buff(3), { desc = "Goto third last used buffer" })
map("n", "<M-4>", goto_buff(4), { desc = "Goto fourth last used buffer" })
map("n", "<M-5>", goto_buff(5), { desc = "Goto fifth last used buffer" })

-------------------------------------------------------------------------------
-- Fuzzy related                                                             --
-------------------------------------------------------------------------------
map("n", '<M-f>', function()
    return "<cmd>FuzzyFile " .. vim.fn.expand("%:p:h") .. "<cr>"
end, { expr = true, desc = "File selection in current file dir (fuzzy)" })
map("n", "<M-F>", "<cmd>FuzzyFile<cr>", { desc = "File selection (fuzzy)" })
map("n", "<leader>k", "<cmd>FuzzyKey<cr>", { desc = "Search keybindings (fuzzy)" })

-------------------------------------------------------------------------------
-- LSP and autocompletion related                                            --
-------------------------------------------------------------------------------
map("n", "<leader>d", deprecated("Use <c-w>d to show diagnostics"))
map("n", "<leader>D", deprecated("Use <c-w><c-d> to open diagnostics window"))
map("n", "<leader>ld", deprecated("Use grd to go to declaration"))
map("n", "<leader>lD", deprecated("Use grt to go to definition"))
map("n", "<leader>la", deprecated("Use gra to use trigger code action"))
map("n", "<leader>lr", deprecated("Use grn to rename"))

-- remap autocompletion to Ctrl+Enter
map("i", "<C-CR>", "<C-Y>")

-- NOTE for some reason declaration is not bound by default??
map("n", "grd", vim.lsp.buf.declaration, { desc = "Go to declaration (LSP)" })
map("n", "<c-w><c-d>", vim.diagnostic.setloclist, { desc = "Open diagnostics window" })
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format file (LSP)" })

-- this could be triggered with `<c-o>K` but its a pain
map("i", "<c-k>", vim.lsp.buf.hover, { desc = "Trigger hover in insert mode (LSP)" })
map("i", "<c-space>", vim.lsp.completion.get, { desc = "Trigger autocompletion (LSP)" })

-------------------------------------------------------------------------------
-- Toggles                                                                   --
-------------------------------------------------------------------------------
map("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })
map("n", "<leader>ti", function()
    -- toggle inlay for current buffer
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), 0)
end, { desc = "Toggle inlay hints (LSP)" })
