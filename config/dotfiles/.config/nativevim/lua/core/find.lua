-- pure lua implementation or find

local uv = vim.uv or vim.loop
local joinpath = vim.fs.joinpath
local const = require("core.constants")
local M = {}

-- directories with these names are not searched
M.ignore_dir_list = {
    [".git"] = true,
    ["build"] = true,
    ["target"] = true,
    ["generated"] = true,
    ["__pycache__"] = true,
    ["venv"] = true,
    [".venv"] = true,
    [".env"] = true,
    ["node_modules"] = true,
}

-- files with these extensions are not listed
M.ignore_ext_list = {
    [".mp3"] = true,
    [".mp4"] = true,
    [".mkv"] = true,
    [".png"] = true,
    [".jpeg"] = true,
    [".jpg"] = true,
    [".gif"] = true,
    [".o"] = true,
    [".obj"] = true,
    [".stl"] = true,
    [".3mf"] = true,
    [".pyc"] = true,
    [".zip"] = true,
    [".rar"] = true,
    [".tar"] = true,
    [".gz"] = true,
    [".xz"] = true,
}

function M.find_files_raw(root, filter_dir, filter_file, max_depth, timeout)
    local fs_scandir = uv.fs_scandir
    local fs_scandir_next = uv.fs_scandir_next
    local files = {}

    if not root or root == "" then
        error("Empty root for get_files")
    end

    local timeout_ns = timeout * 1e6 -- convert to nanosec
    local start_time = vim.uv.hrtime()

    local function scan(path, depth)
        local handle = fs_scandir(path)
        if not handle then return false end

        -- signal stop when timeout has reached
        if (vim.uv.hrtime() - start_time) > timeout_ns then
            return true
        end

        depth = depth or 0
        if depth > max_depth then return false end

        while true do
            local name, type = fs_scandir_next(handle)
            if not name then break end

            local full_path = joinpath(path, name)

            if type == "directory" then
                if filter_dir(full_path, name) == true then
                    if scan(full_path, depth + 1) then
                        return true
                    end
                end
            elseif type == "file" then
                if filter_file == nil or filter_file(full_path, name) == true then
                    if vim.startswith(full_path, "./") then
                        table.insert(files, full_path:sub(3))
                    else
                        table.insert(files, full_path)
                    end
                end
            end
        end

        return false
    end

    -- expand user home
    local expanded_root = vim.fn.expand(root)
    local timeout_reached = scan(expanded_root)
    return files, timeout_reached
end

local home = os.getenv("HOME")
function M.find_files(root, max_depth, timeout)
    return M.find_files_raw(
        (root or "."),
        function(full_path, name)
            -- remove .confg, .local and other garbage from home
            if vim.startswith(full_path, joinpath(home, ".")) then
                return false
            end

            -- filter with the ignore list
            if M.ignore_dir_list[name] then
                return false
            end

            return true
        end,

        function(_, name)
            -- filter with extension ignore list
            local ext = vim.fn.fnamemodify(name, ":r")
            if M.ignore_ext_list[ext] then
                return false
            end

            return true
        end,
        (max_depth or const.max_depth),
        (timeout or const.timeout)
    )
end

return M
