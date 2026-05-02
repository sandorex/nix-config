-- highlights keywords like TODO NOTE FIXME etc

-- add highlight each time buffer is entered
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        -- NOTE add groups in containedin if it does not work for it
        vim.cmd([[
            syntax keyword myTodo TODO FIXME IMPORTANT NOTE SAFETY containedin=Comment,shComment,htmlComment
            highlight link myTodo Todo
        ]])
    end,
})

local function refresh()
    -- more readable highlighting
    vim.api.nvim_set_hl(0, "Todo", { fg = "fg", bg = "bg", bold = true, reverse = true })
end

-- apply after colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = refresh,
})

refresh()

