-- all keybindings should be here

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

-- TODO i think this is messing up paste without deleting selected
-- map("v", "p", "\"_dP", { desc = "Paste without yanking", silent = true })
map("n", "<s-u>", "<cmd>redo<cr>", { desc = "Redo" })

-- easy system clipboard copy / paste by prefixing with <leader>
map({"n", "v"}, "<leader>y", '"+y')
map("n", "<leader>Y", '"+yg_')
map("n", "<leader>y", '"+y')

map({"n", "v"}, "<leader>p", '"+p')
map({"n", "v"}, "<leader>P", '"+P')

-- buffer stuff
map("n", "<leader>b", ":ls<cr>:b<space>", { desc = "Macro to list buffers" })
map("n", "<BS>", "<cmd>b#<cr>", { desc = "Switch to previous buffer" })
map("n", "<c-b>", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })

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

-------------------------------------------------------------------------------
-- Fuzzy related (requires fzy and rg)                                       --
-------------------------------------------------------------------------------
--- TODO the fuzzy plugin should check for its dependencies itself
    map("n", "<leader>b", "<cmd>:FuzzyBuffers<cr>", { desc = "Fuzzy buffer selection" })
    map("n", "<M-f>", "<cmd>:FuzzyFile:s<cr>", { desc = "Fuzzy file selection" })
    map("n", '<M-F>', function ()
        return "<cmd>:FuzzyFile " .. vim.fn.expand("%:p:h") .. "<cr>"
    end, { expr = true, desc = "Fuzzy file selection (cwd)" })

-------------------------------------------------------------------------------
-- LSP and autocompletion related                                            --
-------------------------------------------------------------------------------
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- remap autocompletion to Ctrl+Enter
map("i", "<C-CR>", "<C-Y>")

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
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

