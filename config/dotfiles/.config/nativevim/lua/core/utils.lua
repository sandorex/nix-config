local M = {}

-- TLDR for snippets
--
-- The syntax is defined by microsoft LSP protocol
-- `$0...$n` placeholders with $0 being the last one
-- `${1:default}` placeholder with default value
-- `${1|one,two|}` placeholder with two options
--
-- Some special variables
--   TM_SELECTED_TEXT The currently selected text or the empty string
--   TM_CURRENT_LINE The contents of the current line
--   TM_CURRENT_WORD The contents of the word under cursor or the empty string
--   TM_LINE_INDEX The zero-index based line number
--   TM_LINE_NUMBER The one-index based line number
--   TM_FILENAME The filename of the current document
--   TM_FILENAME_BASE The filename of the current document without its extensions
--   TM_DIRECTORY The directory of the current document
--   TM_FILEPATH The full file path of the current document--
--
-- More at https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#snippet_syntax

--- Global snippets
M.snippets = {
    global = {}
}

-- TODO add vim.validate
local function define_snippet(ftype, name, text_or_fn, desc)
    local entry = {}

    entry["desc"] = desc

    if type(text_or_fn) == "string" then
        entry["text"] = vim.trim(text_or_fn)
    elseif type(text_or_fn) == "function" then
        entry["func"] = text_or_fn
    end

    if not M.snippets[ftype] then
        M.snippets[ftype] = {}
    end

    M.snippets[ftype][name] = entry
end

local function find_snippet(ftype, name)
    return (M.snippets[ftype] or {})[name] or M.snippets["global"][name] or nil
end

--- Defines a snippet for all files and buffers
function M.global_snippet(name, text, desc)
    define_snippet("global", name, text, desc)
end

--- Defines a snippet (if ftype is not provided then defaults to `vim.bo.filetype`)
function M.snippet(name, text, desc, ftype)
    define_snippet(ftype or vim.bo.filetype, name, text, desc)
end

--- Try to expand snippet under cursor or provided one
function M.try_expand_snippet()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local raw_line = vim.api.nvim_get_current_line()

    -- extract the snippet
    -- NOTE: i couldnt use <cword> as it does not match when cursor is at end of
    -- word like `mod|`
    local name = string.match(raw_line:sub(1, col), "([%w_]+)$")
    if not name or name == "" then
        return
    end

    -- local snippet = (M.snippets[""] or {})[name] or M.snippets[name] or nil
    local snippet = find_snippet(vim.bo.filetype, name)
    if snippet then
        if snippet.text then
            -- remove the snippet name
            local line = raw_line:sub(1, col - #name) .. raw_line:sub(col + 1)
            vim.api.nvim_set_current_line(line)
            vim.api.nvim_win_set_cursor(0, {row, col - #name})

            vim.snippet.expand(snippet.text)
        elseif snippet.func then
            snippet.func()
        end
    else
        vim.notify("Invalid snippet '" .. name .. "'", vim.log.levels.WARN)
    end
end

--- Automatically maps pairs "{}" -> "{|}" with | being the cursor, works for
--- any length of pairs but cursor will always be after the first character
function M.map_autopairs(pairs)
    for _, i in ipairs(pairs) do
        vim.keymap.set("i", i:sub(1, 1), i .. string.rep("<left>", i:len() - 1), { buffer = true })
    end
end

-- TODO would using getbufinfo alone be more efficient?
function M.get_buffers_by_last_used()
    local bufs = vim.api.nvim_list_bufs()
    local result = {}

    for _, buf in ipairs(bufs) do
        -- only show listed and valid buffers
        -- also do not include current buffer
        if vim.api.nvim_buf_is_valid(buf)
                and vim.bo[buf].buflisted
                and buf ~= vim.api.nvim_get_current_buf() then
            local info = vim.fn.getbufinfo(buf)[1]
            table.insert(result, {
                buf = buf,
                name = info.name,
                lastused = info.lastused,
                changed = info.changed,
            })
        end
    end

    -- sort the files by most recent
    table.sort(result, function(a, b)
        return a.lastused > b.lastused
    end)

    return result
end

function M.tbl_find(val, tbl)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return nil
end

return M
