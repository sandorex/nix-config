if vim.fn.has("nvim-0.11") == 0 then
    vim.notify("Configuration only supports Neovim 0.11+", vim.log.levels.ERROR)
    return
end

-- load catppuccin at start
vim.cmd("colorscheme catppuccin_macchiato")

-- builtin plugins
vim.cmd("packadd! yuck.vim")

-- load lazy core commands
require("core")

-- load the config
require("config")

