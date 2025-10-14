vim.d = vim.d or {}

function vim.d.get_themes()
    local themes = vim.fn.getcompletion("", "color")
    local xs = {}
    for _, name in ipairs(themes) do
        table.insert(xs, name)
    end
    return xs
end

function vim.d.select_theme()
  local start = vim.g.colors_name
  vim.g.__theme_selected = false
  require('telescope.builtin').colorscheme {
    enable_preview = true,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      local function apply_and_close()
        local entry = action_state.get_selected_entry()
        vim.g.__theme_selected = true
        actions.close(prompt_bufnr)
        if entry and entry.value then
          pcall(vim.cmd.colorscheme, entry.value)
        end
      end

      local function restore_and_close()
        actions.close(prompt_bufnr)
        if not vim.g.__theme_selected and start then
          pcall(vim.cmd.colorscheme, start)
        end
      end

      map('i', '<CR>', apply_and_close)
      map('n', '<CR>', apply_and_close)
      map('i', '<Esc>', restore_and_close)
      map('n', '<Esc>', restore_and_close)
      map('i', '<C-c>', restore_and_close)
      map('n', '<C-c>', restore_and_close)
      return true
    end,
  }
end
