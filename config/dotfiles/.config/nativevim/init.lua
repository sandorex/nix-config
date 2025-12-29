if vim.fn.has("nvim-0.11") == 0 then
    vim.notify("NativeVim only supports Neovim 0.11+", vim.log.levels.ERROR)
    return
end

-- load catppuccin at start
vim.cmd("colorscheme catppuccin_macchiato")

require("core.options")
require("core.treesitter")
require("core.lsp")
require("core.statusline")
require("core.keybindings")
require("core.functions")
require("plugins")
