vim.api.nvim_create_user_command("LspLog", function()
    local log_file = require('vim.lsp.log').get_filename()
    vim.cmd(":edit " .. log_file)
end, { desc = "Opens the LSP log file" })

vim.api.nvim_create_user_command("LspList", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    local output = {}
    for _, lsp in ipairs(clients) do
        local buffers = {}
        for key, _ in pairs(lsp.attached_buffers) do
            table.insert(buffers, key)
        end

        table.insert(output, lsp.config.name .. " [" .. vim.fn.join(buffers, ", ") .. "]")
    end

    print(vim.fn.join(output, "\n"))
end, { desc = "List all LSPs and their buffers" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client == nil then
            return
        end

        if client:supports_method("textDocument/completion") then
            -- autotrigger can be annoying as it depends on server defined keys
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
                autotrigger = false
            })
        end

        -- if client supports folding then use it
        if client:supports_method('textDocument/foldingRange') then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win][0].foldmethod = 'expr'
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
            vim.wo[win][0].foldtext = 'v:lua.vim.lsp.foldtext()'
        end

        -- add lsp dirs to path
        local lsp_folders = vim.lsp.buf.list_workspace_folders()
        if lsp_folders ~= nil then
            -- limit to depth of 3
            for _, path in ipairs(lsp_folders) do
                vim.opt.path:prepend(path .. "/**3")
            end
        end
    end,
})

-- all enabled lsp configurations lsp/*.lua
vim.lsp.enable {
    "lua_ls",
    "godot", -- requires nc
    "rust_analyzer",
    "basedpyright",
    "nixd",
}
