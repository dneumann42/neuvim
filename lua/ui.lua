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

local UI = {}

function UI.setup()
    vim.api.nvim_create_user_command("SwitchTheme", function() vim.d.select_theme() end, {})
    vim.opt.laststatus = 3
    vim.opt.cmdheight = 0
    vim.opt.showmode = false
    -- always show sign column
    vim.cmd([[ set scl=yes ]])

    vim.opt.clipboard:append("unnamedplus")

    vim.opt.hlsearch = true
    vim.opt.incsearch = true
    vim.opt.autoindent = true
    vim.opt.wildmode = "longest,list"
    vim.opt.syntax = "on"

    vim.cmd([[ filetype plugin indent on ]])
    vim.cmd([[ filetype plugin on ]])

    vim.opt.mouse = "a"
    vim.opt.encoding = "utf-8"
    vim.opt.ttyfast = true
    vim.opt.swapfile = true
    vim.opt.backupdir = os.getenv("HOME") .. "/.cache/vim"
end

function UI.setup_statusline()
    local mode_labels = {
        n = "NORMAL",
        v = "VISUAL",
        V = "VISUAL LINE",
        s = "SELECT",
        S = "SELECT LINE",
        i = "INSERT",
        ic = "INSERT",
        R = "REPLACE",
        Rv = "VISUAL REPLACE",
        c = "COMMAND",
        cv = "VIM EX",
        ce = "EX",
        r = "PROMPT",
        rm = "MOAR",
        t = "TERMINAL",
        ["r?"] = "CONFIRM",
        ["!"] = "SHELL",
        ["␓"] = "SELECT BLOCK",
        ["␖"] = "VISUAL BLOCK",
    }

    local mode_colors = {
        n = "%#StatuslineAccent#",
        i = "%#StatuslineInsertAccent#",
        ic = "%#StatuslineInsertAccent#",
        v = "%#StatuslineVisualAccent#",
        V = "%#StatuslineVisualAccent#",
        ["␖"] = "%#StatuslineVisualAccent#",
        R = "%#StatuslineReplaceAccent#",
        c = "%#StatuslineCmdLineAccent#",
        t = "%#StatuslineTerminalAccent#"
    }

    local function get_mode_label()
        local mode = vim.api.nvim_get_mode().mode
        return mode_labels[mode] or "UNKNOWN"
    end

    local function get_mode_color()
        local mode = vim.api.nvim_get_mode().mode
        return mode_colors[mode] or "%#StatuslineAccent#"
    end

    local function get_filename()
        local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
        local base = (fpath == "" or fpath == ".") and " " or string.format(" %%<%s/", fpath)
        local fname = vim.fn.expand("%:t")
        return fname == "" and "" or base .. fname
    end

    local function get_line_info()
        return "%=[%l/%L] (%p%%) col:%c"
    end

    local function get_lsp()
        local sev = vim.diagnostic.severity
        local icons = {
            [sev.ERROR] = "%#LspDiagnosticsSignError#",
            [sev.WARN]  = "%#LspDiagnosticsSignWarning#",
            [sev.INFO]  = "%#LspDiagnosticsSignInformation#",
            [sev.HINT]  = "%#LspDiagnosticsSignHint#󰌵",
        }
        local order = { sev.ERROR, sev.WARN, sev.INFO, sev.HINT }
        local parts = {}
        for _, s in ipairs(order) do
            local n = #vim.diagnostic.get(0, { severity = s })
            if n > 0 then table.insert(parts, icons[s] .. " " .. n) end
        end
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, c.name)
        end
        local label = #names > 0 and (" [" .. table.concat(names, ",") .. "]") or ""
        return table.concat(parts, " ") .. label
    end

    _G.statusline = {
        active = function()
            return table.concat {
                get_mode_color(),
                get_mode_label(),
                get_filename(),
                " ",
                get_lsp(),
                get_line_info()
            }
        end,
        inactive = function()
            return " %F"
        end
    }

    vim.cmd([[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.statusline.active()
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.statusline.inactive()
  au WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.Statusline.inactive()
  augroup END
]], false)
end

return UI
