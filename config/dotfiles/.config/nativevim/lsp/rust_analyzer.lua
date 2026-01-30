-- does not make sense to run rust_analyzer in a container

---@type vim.lsp.Config
return {
    cmd = { "rust-analyzer" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },
    filetypes = { "rust" },
    capabilities = {
        experimental = {
            -- taken from nvim-lspconfig
            serverStatusNotification = true,
        },
    },
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                -- use separate directory for rust-analyzer to prevent stalls
                -- or clobbering of cache
                targetDir = true,
            },
        },
    },
}

