-- all user functions

vim.api.nvim_create_user_command("LspLog", function()
    local log_file = require('vim.lsp.log').get_filename()
    vim.cmd(":edit " .. log_file)
end, { desc = "Opens the LSP log file" })

-- same as :make command but async
local function async_make(args)
  local lines = {""}
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local makeprg = vim.b[bufnr].makeprg or vim.o.makeprg
  local errorformat = vim.b[bufnr].errorformat or vim.o.errorformat

  if not makeprg or not errorformat then
      print("Error: please set makeprg and errorformat")
      return
  end

  local cmd = vim.fn.expandcmd(makeprg)

  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == "exit" then
      vim.fn.setqflist({}, " ", {
        title = cmd,
        lines = lines,
        efm = errorformat
      })

      vim.api.nvim_command("doautocmd QuickFixCmdPost")

      -- open quickfixlist automatically
      if args.bang ~= true then
          vim.api.nvim_command("botright copen")
      end
    end
  end

  -- close quickfixlist
  vim.api.nvim_command("cclose")

  local job_id =
    vim.fn.jobstart(
    cmd,
    {
      on_stderr = on_event,
      on_stdout = on_event,
      on_exit = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )
end

vim.api.nvim_create_user_command("Make", async_make, { desc = "Async version of :make" })
