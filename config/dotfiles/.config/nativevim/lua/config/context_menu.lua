-- remove builtin neovim autocmd (removing some items causes errors)
vim.api.nvim_clear_autocmds({ group = "nvim.popupmenu" })

vim.cmd [[
    aunmenu       PopUp
    amenu         PopUp.Open\ URL                 <cmd>lua vim.ui.open(vim.fn.expand("<cWORD>"))<CR>
    vnoremenu     PopUp.Cut                       "+x
    vnoremenu     PopUp.Copy                      "+y
    anoremenu     PopUp.Paste                     "+gP
    vnoremenu     PopUp.Paste                     "+P
    vnoremenu     PopUp.Delete                    "_x
    nnoremenu     PopUp.Back                      <C-t>
    nnoremenu     PopUp.Select\ All               ggVG
    vnoremenu     PopUp.Select\ All               gg0oG$
    inoremenu     PopUp.Select\ All               <C-Home><C-O>VG
    amenu         PopUp.-2-                       <NOP>
    anoremenu     PopUp.Definition                <cmd>lua vim.lsp.buf.definition()<CR>
    anoremenu     PopUp.References                <cmd>lua vim.lsp.buf.references()<CR>
    anoremenu     PopUp.Show\ Diagnostics         <cmd>lua vim.diagnostic.open_float()<CR>
    anoremenu     PopUp.Show\ All\ Diagnostics    <cmd>lua vim.diagnostic.setqflist()<CR>
]]

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
  pattern = "*",
  group = group,
  desc = "Custom PopUp Setup",
  callback = function()
    vim.cmd [[
        amenu disable PopUp.Open\ URL
        amenu disable PopUp.-2-
        amenu disable PopUp.Definition
        amenu disable PopUp.References
        amenu disable PopUp.References
        amenu disable PopUp.Show\ Diagnostics
        amenu disable PopUp.Show\ All\ Diagnostics
    ]]

    -- only show in normal mode and when there is a LSP
    if vim.fn.mode() == "n" and vim.lsp.get_clients({ bufnr = 0 })[1] then
        vim.cmd [[
            amenu enable PopUp.-2-
            amenu enable PopUp.Definition
            amenu enable PopUp.References
            amenu enable PopUp.References
            amenu enable PopUp.Show\ Diagnostics
            amenu enable PopUp.Show\ All\ Diagnostics
        ]]
    end

    -- show option to open url if its a url
    local url = vim.fn.expand("<cWORD>")
    if vim.startswith(url, "http") then
        vim.cmd [[ amenu enable PopUp.Open\ URL ]]
    end
  end,
})
