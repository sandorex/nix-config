-- this is a fork of pyls
-- https://github.com/python-lsp/python-lsp-server

---@type vim.lsp.Config
return {
    cmd = { "pylsp" },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
    filetypes = { "python" },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    'E302', -- expected 2 blank lines..
                    'E402', -- module import not at top..
                    'W391', -- empty line on end of file
                    'E261', -- 2 spaces before inline comment..
                    'E305', -- 2 lines after statement blah blah..
                },
            },
        },
    },
}

