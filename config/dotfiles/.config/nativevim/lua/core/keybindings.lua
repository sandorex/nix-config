-- all keybindings should be here

-- make wildchar trigger autocompletion in command mode (<tab> by default)
vim.o.wildcharm = vim.o.wildchar

local function map(modes, lhs, rhs, args)
    vim.keymap.set(modes, lhs, rhs, args or {})
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
map("n", "<leader>f", "<cmd>e .<cr>", { desc = "netrw cwd" })
map("n", "<leader>F", "<cmd>e %:p:h<cr>", { desc = "netrw cur buf dir" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = ":w" })
-- map("n", "<leader>q", "<cmd>q<cr>", { desc = ":q" })

-- easy clipboard copy / paste by prefixing with <leader>
map({"n", "v"}, "<leader>y", '"+y')
map("n", "<leader>Y", '"+yg_')
map("n", "<leader>y", '"+y')

map({"n", "v"}, "<leader>p", '"+p')
map({"n", "v"}, "<leader>P", '"+P')

-- buffer management
map("n", "<leader>b", ":buffer<space><tab>", { desc = "Select buffer shorthand", silent = false })
map("n", "<c-x>", "<cmd>bprev<cr>", { desc = "Goto prev buffer" })
map("n", "<c-c>", "<cmd>bnext<cr>", { desc = "Goto next buffer" })
map("n", "<c-b>", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })

map("v", "p", "\"_dP", { desc = "Paste without yanking", silent = true })
map("n", "<s-u>", "<cmd>redo<cr>", { desc = "Redo" })

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
-- Quickfix list                                                             --
-------------------------------------------------------------------------------
map("n", "<leader>q", "<cmd>copen<cr>", { desc = "Open quickfix list" })
map("n", "<leader>e", "<cmd>cnext<cr>", { desc = "Next error in quickfix list" })

-------------------------------------------------------------------------------
-- LSP and autocompletion related                                            --
-------------------------------------------------------------------------------
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- remap autocompletion to Ctrl+Enter
map("i", "<C-CR>", "<C-Y>")

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        map("n", "<leader>g", vim.lsp.buf.declaration, { desc = "Goto declaration (LSP)" })
        map("n", "<leader>G", vim.lsp.buf.definition, { desc = "Goto definition (LSP)" })
        map("n", "<leader>a", vim.lsp.buf.code_action, { desc = "Code action (LSP)" })

        map("i", "<c-w>", vim.lsp.buf.hover, { silent = true, desc = "Trigger hover in insert mode (LSP)" })
        map("i", "<c-space>", vim.lsp.completion.get, { silent = true, desc = "Trigger autocompletion (LSP)" })
    end,
})
