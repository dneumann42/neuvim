local sessdir = vim.fn.stdpath("state") .. "/sessions"
vim.fn.mkdir(sessdir, "p")
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,globals,skiprtp"

local function session_path()
  return ("%s/%s.vim"):format(sessdir, vim.fn.sha256(vim.fn.getcwd()))
end

local function save_session()
  vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session_path()))
end

vim.api.nvim_create_autocmd("CmdlineEnter", {
  pattern = { "qa", "qall", "quit", "exit", "wqa", "x", "wq", "restart" },
  callback = save_session,
})

vim.api.nvim_create_autocmd("CmdlineLeave", { callback = save_session })
