-- im not gonna even bother downloading extra treesitter grammars until it is
-- easier to do

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        -- run treesitter only if it has language for that
        if vim.treesitter.language.add(args.match) then
            vim.treesitter.start(args.buf, args.match)

            vim.b.foldmethod = "expr" -- use tree-sitter for folding method
            vim.b.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end
})
