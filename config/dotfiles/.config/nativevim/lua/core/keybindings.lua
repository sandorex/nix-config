-- all keybindings should be here

-- make wildchar trigger autocompletion in command mode (<tab> by default)
vim.o.wildcharm = vim.o.wildchar

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = ":w" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = ":q" })

vim.keymap.set("n", "<leader>f", "<cmd>e .<cr>", { desc = "netrw cwd" })
vim.keymap.set("n", "<leader>F", "<cmd>e %:p:h<cr>", { desc = "netrw cur buf dir" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>D", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

vim.keymap.set("i", "<c-space>", vim.lsp.completion.get, { silent = true, desc = "Trigger autocompletion" })
vim.keymap.set("i", "<c-w>", vim.lsp.buf.hover, { silent = true, desc = "Trigger hover in insert mode" })

vim.keymap.set("n", "<c-x>", "<cmd>bprev<cr>", { desc = "Goto prev buffer" })
vim.keymap.set("n", "<c-c>", "<cmd>bnext<cr>", { desc = "Goto next buffer" })
vim.keymap.set("n", "<c-b>", "<cmd>bdelete<cr>", { desc = "Delete current buffer" })

-- wildcharm --
vim.keymap.set("n", "<leader>b", ":buffer<space><tab>", { desc = "Select buffer shorthand", silent = false })

--- remaps of builtin functionality ---
vim.keymap.set("v", "p", "\"_dP", { desc = "Paste without yanking", silent = true })
vim.keymap.set("n", "<s-u>", "<cmd>redo<cr>", { desc = "Redo" })

-- make <Up>/<Down> respect word wrap
vim.keymap.set('i', '<Up>', "v:count == 0 ? '<C-o>gk' : '<C-o>k'", { expr = true, silent = true })
vim.keymap.set('i', '<Down>', "v:count == 0 ? '<C-o>gj' : '<C-o>j'", { expr = true, silent = true })
vim.keymap.set({'n', 'v'}, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({'n', 'v'}, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- move content lines
vim.keymap.set('n', '<M-Up>', '<cmd>m .-2<cr>==', { desc = 'Move line up', silent = true })
vim.keymap.set('n', '<M-Down>', '<cmd>m .+1<cr>==', { desc = 'Move line down', silent = true })
vim.keymap.set('v', '<M-Up>', ":m '<-2<cr>gv=gv", { desc = 'Move lines up', silent = true })
vim.keymap.set('v', '<M-Down>', ":m '>+1<cr>gv=gv", { desc = 'move lines down', silent = true })

