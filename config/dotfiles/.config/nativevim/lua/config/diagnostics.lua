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

local ns = vim.api.nvim_create_namespace("qfl2diag")
local function to_diag(list, buf, source)
    local diagnostics = vim.diagnostic.fromqflist(list, { merge_lines = true })

    -- so it can be differentiated from LSP if running
    for i = 1, #diagnostics do
        diagnostics[i].source = source
    end

    vim.diagnostic.set(ns, buf, diagnostics)
end
local function qfl2diag(buf) to_diag(vim.fn.getqflist(), buf or 0, "qfl") end
local function loclist2diag(buf) to_diag(vim.fn.getloclist(), buf or 0, "loclist") end

-- automaically load qfl as diagnostics, for LSP-like experience
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
    callback = function()
        local qfl_size = vim.fn.getqflist({ size = true }).size
        if qfl_size > 0 then
            qfl2diag()
        end
    end,
})

vim.api.nvim_create_user_command("Dqfl", function() qfl2diag() end, { desc = "Load quickfixlist into diagnostics" })
vim.api.nvim_create_user_command("Lqfl", function() loclist2diag() end, { desc = "Load loclist into diagnostics" })
