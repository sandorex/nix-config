local opt = vim.opt

-- 4 spaces indentation
opt.tabstop = 4
opt.shiftwidth = 0
opt.expandtab = true

-- TODO
-- vim.cmd("filetype indent off")

-- https://unix.stackexchange.com/questions/106526/stop-vim-from-messing-up-my-indentation-on-comments
--
-- /nix/store/f5l29nrlmqsjfm8gwnd4038izih7k25z-neovim-unwrapped-0.12.2/share/nvim/runtime/indent/nu.vim is the culprit!!
