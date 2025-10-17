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

local function find_netrw_autoload()
    -- 1) $VIMRUNTIME/autoload/netrw.vim
    local vr = vim.env.VIMRUNTIME
    if vr then
        local p = vr .. "/autoload/netrw.vim"
        if vim.uv.fs_stat(p) then return p end
    end
    -- 2) &runtimepath
    local hits = vim.fn.globpath(vim.o.runtimepath, "autoload/netrw.vim", true, true)
    if #hits > 0 then return hits[1] end
    -- 3) Bob nightly fallback (your path hint)
    -- Search broadly for .../pack/dist/opt/netrw/autoload/netrw.vim
    local patterns = {
        "**/pack/dist/opt/netrw/autoload/netrw.vim",
        "share/bob/nightly/share/nvim/runtime/pack/dist/opt/netrw/autoload/netrw.vim",
    }
    local bases = {
        vim.fn.stdpath("data"),
        vim.fn.stdpath("cache"),
        vim.fn.stdpath("config"),
        vim.loop.os_homedir(),
        "/",
    }
    for _, base in ipairs(bases) do
        for _, pat in ipairs(patterns) do
            local g = vim.fn.glob(base .. "/" .. pat, true, true)
            if type(g) == "table" and #g > 0 then return g[1] end
            if type(g) == "string" and g ~= "" then return g end
        end
    end
    return nil
end

local function writefile(path, text)
    return pcall(vim.fn.writefile, vim.split(text, "\n", { plain = true }), path)
end

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

    vim.opt.mouse               = "a"
    vim.opt.encoding            = "utf-8"
    vim.opt.ttyfast             = true
    vim.opt.swapfile            = true
    vim.opt.backupdir           = vim.env.HOME .. "/.cache/vim"

    vim.g.netrw_liststyle       = 3
    vim.g.netrw_banner          = 0
    vim.g.netrw_keepdir         = 0
    vim.g.netrw_winsize         = 20
    vim.g.netrw_localcopydircmd = "cp -r"

    vim.cmd [[ hi! link netrwMarkFile Search ]]

    require("settings")
    local bindings = vim.d.bindings

    local function netrw_toggle()
        local current_tab = vim.api.nvim_get_current_tabpage()
        local netrw_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "netrw" then
                netrw_win = win
                break
            end
        end
        if netrw_win then
            vim.api.nvim_win_close(netrw_win, true)
            return
        end
        if vim.fn.expand("%") ~= "" then
            vim.cmd("Lexplore %:p:h")
        else
            vim.cmd("Lexplore")
        end
        vim.cmd("wincmd p")
    end

    vim.keymap.set("n", bindings.netrw_toggle, netrw_toggle, { desc = "Toggle Netrw" })

    vim.g.netrw_hide = 1
    vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "netrw",
        callback = function()
            vim.keymap.set("n", "H", "gh", { buffer = true, remap = true, desc = "Toggle dotfiles" })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "netrw",
                callback = function()
                    vim.keymap.set("n", "<Tab>", "<CR>",
                        { buffer = true, remap = true, desc = "Expand/collapse or open" })
                    vim.keymap.set("n", "<S-Tab>", "<CR>",
                        { buffer = true, remap = true, desc = "Expand/collapse or open" })
                end,
            })
        end,
    })
end

return UI
