local settings = require("settings")

vim.g.mapleader = settings.mapleader

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

vim.opt.number = true
vim.opt.relativenumber = true

function vim.d.set_tab_size(size)
    vim.o.tabstop = lua_tab_size
    vim.o.shiftwidth = lua_tab_size
    vim.o.softtabstop = lua_tab_size
    vim.o.expandtab = true
end

vim.d.set_tab_size(settings.tab_size)

-- Auto pairs
local ps = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`",
}

for open, close in pairs(ps) do
  vim.keymap.set("i", open, function()
    return open .. close .. "<Left>"
  end, { expr = true })

  -- close char should just skip over if already there
  vim.keymap.set("i", close, function()
    local col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    if line:sub(col, col) == close then
      return "<Right>"
    else
      return close
    end
  end, { expr = true })
end
