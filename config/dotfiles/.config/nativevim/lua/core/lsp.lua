vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client == nil then
            return
        end

        if client:supports_method("textDocument/completion") then
            -- autotrigger can be annoying as it depends on server defined keys
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = false })
        end

        -- -- enable inlay hints by default
        -- if client.server_capabilities.inlayHintProvider then
        --     vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        -- end

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
    "rust_analyzer"
}

