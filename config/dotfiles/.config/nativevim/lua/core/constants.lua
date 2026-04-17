-- contains constants which are used across multiple modules
local M = {}

--- Default timeout in millis for functions blocking like recursive find
M.timeout = vim.g.core_timeout or 600

--- Default maximum depth to go to when searching for files
M.max_depth = 6

--- Suffix and prefix for snippets
M.snippet_key = ","

return M
