-- all keybindings should be here

local core = require("core.utils")

-- make wildchar trigger autocompletion in command mode (<tab> by default)
vim.o.wildcharm = vim.o.wildchar

local map = vim.keymap.set

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
map("n", "<leader>f", "<cmd>e .<cr>", { desc = "netrw cwd" })
map("n", "<leader>F", "<cmd>e %:p:h<cr>", { desc = "netrw cur buf dir" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

map("n", "<s-u>", "<cmd>redo<cr>", { desc = "Redo" })

-- easy system clipboard copy / paste by prefixing with <leader>
map({"n", "v"}, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>Y", '"+yg_', { desc = "Copy line to system clipboard" })

map({"n", "v"}, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({"n", "v"}, "<leader>P", '"+P', { desc = "Paste from system clipboard" })

-- paste without yanking in visual mode
-- TODO i cannot change the register by prefixing it with "2 this needs to be
-- user command with register = true
map('v', 'p', function()
    vim.fn.setreg('x', vim.fn.getreg('"'))
    vim.api.nvim_paste(vim.fn.getreg('"'), {}, -1)
    vim.fn.setreg('"', vim.fn.getreg('x'))
end, { silent = true })

-- buffer stuff
map("n", "<leader>b", "<cmd>ChooseBuffer<cr>", { desc = "Choose buffer" })
map("n", "<C-b>", "<cmd>ChooseBuffer<cr>", { desc = "Choose buffer" })
-- map("n", "<leader>b", ":ls<cr>:b<space>", { desc = "Macro to list buffers" })
map("n", "<M-s>", "<cmd>FuzzyBuffer<cr>", { desc = "Switch buffer (fuzzy)" })
map("n", "<M-b>", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })

-- tab stuff
-- imitate ]b [b for switching buffers
map("n", "]t", "<cmd>tabnext<cr>", { desc = "Goto next tab" })
map("n", "[t", "<cmd>tabprevious<cr>", { desc = "Goto previous tab" })

map("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle word wrap" })

-- make <Up>/<Down> respect word wrap
map("i", "<Up>", "v:count == 0 ? '<C-o>gk' : '<C-o>k'", { expr = true, silent = true })
map("i", "<Down>", "v:count == 0 ? '<C-o>gj' : '<C-o>j'", { expr = true, silent = true })
map({"n", "v"}, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({"n", "v"}, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move content lines
map('n', '<M-Up>', '<cmd>m .-2<cr>==', { desc = 'Move line up', silent = true })
map('n', '<M-Down>', '<cmd>m .+1<cr>==', { desc = 'Move line down', silent = true })
map('v', '<M-Up>', ":m '<-2<cr>gv=gv", { desc = 'Move lines up', silent = true })
map('v', '<M-Down>', ":m '>+1<cr>gv=gv", { desc = 'move lines down', silent = true })

-- surround selection
map("v", '<M-s>"', 'c"<c-r>""', { desc = "Surround with quotes" })
map("v", "<M-s>'", "c'<c-r>\"'", { desc = "Surround with s. quotes" })
map("v", "<M-s>(", 'c(<c-r>")', { desc = "Surround with paren" })
map("v", "<M-s>[", 'c[<c-r>"]', { desc = "Surround with sq. brackets" })
map("v", "<M-s>{", 'c{<c-r>"}', { desc = "Surround with curly brackets" })
map("v", "<M-s><", 'c<<c-r>">', { desc = "Surround with angle brackets" })
map("v", "<M-s>`", 'c`<c-r>"`', { desc = "Surround with backticks" })

-- terminal
map("t", "<c-\\><c-\\>", "<c-\\><c-n>", { desc = "Exit terminal insert mode" })

-- creates a function that just goes to the buffer indexed by last usage
local function goto_buff(index)
    return function()
        local buffers = core.get_buffers_by_last_used()
        if #buffers <= 0 or #buffers < index then
            -- TODO what is a good error message here?
            return
        end

        vim.cmd(":b " .. buffers[index].buf)
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
map("n", "<M-f>", "<cmd>FuzzyFile<cr>", { desc = "File selection (fuzzy)" })
map("n", '<M-F>', function()
    return "<cmd>:FuzzyFile " .. vim.fn.expand("%:p:h") .. "<cr>"
end, { expr = true, desc = "File selection in current file dir (fuzzy)" })
map("n", "<leader>k", "<cmd>FuzzyMap<cr>", { desc = "Search keybindings (fuzzy)" })

-------------------------------------------------------------------------------
-- LSP and autocompletion related                                            --
-------------------------------------------------------------------------------
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- remap autocompletion to Ctrl+Enter
map("i", "<C-CR>", "<C-Y>")

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function()
        -- TODO are these already predefined?? just delete those that are already defined
        map("n", "<leader>ld", vim.lsp.buf.declaration, { desc = "Goto declaration (LSP)" })
        map("n", "<leader>lD", vim.lsp.buf.definition, { desc = "Goto definition (LSP)" })
        map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code action (LSP)" })
        map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format file (LSP)" })
        map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename symbol (LSP)" })

        map("i", "<c-k>", vim.lsp.buf.hover, { silent = true, desc = "Trigger hover in insert mode (LSP)" })
        map("i", "<c-space>", vim.lsp.completion.get, { silent = true, desc = "Trigger autocompletion (LSP)" })

        map("n", "<leader>ti", function()
            -- toggle inlay for current buffer
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), 0)
        end, { desc = "Toggle inlay hints (LSP)" })
    end,
})

