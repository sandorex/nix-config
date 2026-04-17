local sev = vim.diagnostic.severity

vim.diagnostic.config({
    severity_sort = true,
    update_in_insert = false,
    float = {
        -- show source of each diagnostic message if there is more than one
        source = "if_many",
    },
    signs = {
        text = {
            [sev.ERROR] = 'E',
            [sev.WARN]  = 'W',
            [sev.INFO]  = 'I',
            [sev.HINT]  = 'H',
        },
    },
})
