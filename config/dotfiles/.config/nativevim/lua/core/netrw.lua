-- netrw keybindings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
      -- go to next or prev directory with arrow keys
      vim.keymap.set("n", "<left>", "-", { desc = "Go to parent", remap = true, buffer =true })
      vim.keymap.set("n", "<right>", "<cr>", { desc = "Enter", remap = true, buffer = true })
    end,
})

-- autoclose netrw buffers after leaving
-- this sometimes happen i do not know why but its not consistent
vim.api.nvim_create_autocmd("BufLeave", {
    callback = function(ev)
        local ftype = vim.bo[ev.buf].filetype
        if ftype == "netrw" then
            vim.schedule(function()
                vim.api.nvim_buf_delete(ev.buf, {})
            end)
        end
    end,
})

