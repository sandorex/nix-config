-- contains in-process LSP for snippets

local utils = require("core.utils")

local handlers = {}
local ms = vim.lsp.protocol.Methods

local initializeResult = {
    capabilities = {
        completionProvider = {},
    },
    serverInfo = {
        name = "core-lsp-snippet",
        version = "1.0.0",
    },
}

handlers[ms.initialize] = function(_, callback)
    callback(nil, initializeResult)
end

-- very simple completion from defined snippets
handlers[ms.textDocument_completion] = function(_, callback)
    local candidates = {}

    for name, snippet in pairs(utils.get_snippets()) do
        table.insert(candidates, {
            label = name,
            kind = vim.lsp.protocol.CompletionItemKind.Snippet,
            insertText = snippet.text,
            insertTextFormat = 2,
        })
    end

    callback(nil, {
        items = candidates,
        isIncomplete = false,
    })
end

local config = {
    name = initializeResult.serverInfo.name,
    cmd = function()
        return {
            request = function(method, params, callback)
                if handlers[method] then
                    handlers[method](params, callback)
                    return true
                else
                    return false
                end
            end,
            notify = function() end,
            is_closing = function() return false end,
            terminate = function() end,
        }
    end,
}

-- TODO does not run without FileType but eh
-- start on any file
vim.api.nvim_create_autocmd("FileType", {
   pattern = "*",
   callback = function(ev)
       vim.lsp.start(config, { bufnr = ev.buf, silent = false })
   end,
})

