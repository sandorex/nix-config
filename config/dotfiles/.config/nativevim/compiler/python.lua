-- TODO should this be buffer local or global?

-- Check if the current compiler is already set
if vim.g.current_compiler then
    return
end

vim.g.current_compiler = "python"
vim.o.makeprg = "python"

vim.opt.errorformat = {
    "%C %.%#",
    "%A  File \"%f\"\\, line %l%.%#",
    "%Z%[%^ ]%\\@=%m"
}
