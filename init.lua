-- Neovim config by Dustin H. Neumann

vim.d = vim.d or {}

local settings = require("settings")
local sessions = require("sessions")
local plugins = require("plugins")
local terminal = require("terminal")

terminal.setup { height = 12 }

require("editor")

vim.keymap.set({"n","t"}, settings.bindings.toggle_terminal, function() 
    require("terminal").toggle() 
end, { silent = true })

for k, v in pairs(settings.filetype) do
    assert(type(v) == "table")
    vim.api.nvim_create_autocmd("FileType", {
	pattern = k,
	callback = function()
        if v.tab_size then
            assert(type(v.tab_size) == "number")
            vim.bo.tabstop = v.tab_size
            vim.bo.shiftwidth = v.tab_size
            vim.bo.softtabstop = v.tab_size
        end
	end
    })
end

vim.d.update_plugins()
vim.d.update_plugin_configs()

require("ui")
require("nim")

pcall(vim.cmd.colorscheme, settings.color_scheme)
