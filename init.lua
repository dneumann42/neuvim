require("sessions")
require("terminal").setup { height = 12 }

vim.pack.add(require("packages"))

local colorschemes = require("colorschemes")
vim.pack.add(colorschemes)

local lua_tab_size = 4

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
	    vim.bo.tabstop = lua_tab_size
	    vim.bo.shiftwidth = lua_tab_size
	    vim.bo.softtabstop = lua_tab_size
	end
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nim",
	callback = function()
	    vim.bo.tabstop = 4
	    vim.bo.shiftwidth = 4
	    vim.bo.softtabstop = 4
	end
})

vim.g.mapleader = ","

vim.o.tabstop = lua_tab_size
vim.o.shiftwidth = lua_tab_size
vim.o.softtabstop = lua_tab_size
vim.o.expandtab = true

require("catppuccin").setup {
    transparent_background = true,
}

vim.cmd "colorscheme catppuccin"

require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "nim", "lua", "vim", "vimdoc", "query", "bash", "json", "markdown", "markdown_inline", "regex"
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<S-CR>",
          node_decremental = "<BS>",
        },
      },
}
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"

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

require("mini.surround").setup {
      highlight_duration = 5000,
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'cs', -- Replace surrounding

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
}

-- Telescope
require('telescope').setup {
defaults = {
    layout_config = {
      vertical = { width = 0.5 }
    }
  },
  pickers = {
    find_files = {
      heme = "dropdown"
    },
    live_grep = {
      theme = "dropdown"
    }
  },
  extensions = {
    live_grep_args = {
      theme = "dropdown"
    }
  }
}
require('telescope').load_extension("live_grep_args")
require("neo-tree").setup { }
require("nim")

local builtin = require('telescope.builtin')
vim.keymap.set('n', "<leader>f", builtin.find_files, {})
vim.keymap.set('n', "<leader>g", function()
    require("telescope").extensions.live_grep_args.live_grep_args {
      theme = "dropdown"
    }
end, {})

vim.keymap.set('n', "<leader>b", builtin.buffers, {})
vim.keymap.set('n', "<leader>ht", builtin.help_tags, {})
vim.keymap.set({"n","t"}, "<c-space>", function() require("terminal").toggle() end, { silent = true })
vim.keymap.set({"n", "t"}, "<M-0>", function() vim.cmd"Neotree toggle" end)
