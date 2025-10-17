vim.d.bindings = {
    eval_buffer                 = "<C-c>b",
    netrw_toggle                = "<M-0>",

    telescope_find_file         = "<leader>f",
    telescope_find_buffer       = "<leader>b",
    telescope_live_grep         = "<leader>g",
    telescope_help              = "<leader>h",

    toggle_terminal             = "<c-space>",
    neogit_status               = "<space>G",

    surround_add                = "sa",
    surround_delete             = "sd",
    surround_find               = "sf",
    surround_find_left          = "sF",
    surround_highlight          = "sh",
    surround_replace            = "cs",
    surround_suffix_last        = "l",
    surround_suffix_next        = "n",

    dropbar_pick                = "<leader>;",
    dropbar_goto_context_start  = "[;",
    dropbar_select_next_context = "];",

    lsp_definition              = "gd",
    lsp_declaration             = "gD",
    lsp_references              = "gr",
    lsp_implementation          = "gi",
    lsp_hover                   = "K",
    lsp_signature_help          = "<C-k>",
    lsp_rename                  = "grn",
    lsp_code_action             = "<A-CR>",
    lsp_document_symbol         = "gss",
    lsp_document_workspace      = "gsS",
    lsp_format                  = "gf",
}

vim.d.settings = {
    tab_size = 4,
    mapleader = ",",
    auto_session_path = ".local/share/nvim/auto-session.vim",
    color_scheme = "witch-dark",

    bindings = vim.d.bindings,
    filetype = {
        lua = {
            tab_size = 4
        },
        nim = {
            tab_size = 2
        }
    },
    plugins = {
        telescope = {
            opts = {
                defaults = {
                    layout_config = {
                        vertical = { width = 0.5 }
                    }
                },
                pickers = {
                    find_files = {
                        theme = "dropdown"
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
            },
            setup = function(telescope)
                local bindings = vim.d.settings.bindings
                telescope.load_extension("live_grep_args")
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', bindings.telescope_find_file, builtin.find_files, {})
                vim.keymap.set('n', bindings.telescope_find_buffer, builtin.buffers, {})
                vim.keymap.set('n', bindings.telescope_live_grep, function()
                    require("telescope").extensions.live_grep_args.live_grep_args {
                        theme = "dropdown"
                    }
                end, {})
                vim.keymap.set('n', bindings.telescope_help, builtin.help_tags, {})
            end,
        },
        ['dropbar.api'] = {
            setup = function(dropbar_api)
                local bindings = vim.d.settings.bindings
                vim.keymap.set('n', bindings.dropbar_pick, dropbar_api.pick, { desc = 'Pick symbols in winbar' })
                vim.keymap.set('n', bindings.dropbar_goto_context_start, dropbar_api.goto_context_start,
                    { desc = 'Go to start of current context' })
                vim.keymap.set('n', bindings.dropbar_select_next_context, dropbar_api.select_next_context,
                    { desc = 'Select next context' })
            end,
        },
        ['mini.indentscope'] = {
            opts = {
                symbol = '▏',
                draw = {
                    delay = 0,
                }
            },
            setup = function(identscope)
                identscope.gen_animation.none()

                local function set_indent_color()
                    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
                    local function to_rgb(n) return math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256 end
                    local function from_rgb(r, g, b) return string.format("#%02x%02x%02x", r, g, b) end
                    local function lighten(hexnum, amt)
                        local r, g, b = to_rgb(hexnum)
                        r = math.floor(r + (255 - r) * amt)
                        g = math.floor(g + (255 - g) * amt)
                        b = math.floor(b + (255 - b) * amt)
                        return from_rgb(r, g, b)
                    end

                    local fg
                    if normal and normal.bg then
                        fg = lighten(normal.bg, 0.25)
                    else
                        fg = "#6c6c6c"
                    end

                    vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = fg, nocombine = true })
                    vim.api.nvim_set_hl(0, "MiniIndentscopePrefix", { fg = fg, nocombine = true })
                end

                set_indent_color()

                vim.api.nvim_create_autocmd("ColorScheme", { callback = set_indent_color })
            end,
        },
        ['nvim-treesitter.configs'] = {
            opts = {
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
        },
        ['mini.surround'] = {
            opts = {
                highlight_duration = 5000,
                mappings = {
                    add = vim.d.bindings.surround_add,
                    delete = vim.d.bindings.surround_delete,
                    find = vim.d.bindings.surround_find,
                    find_left = vim.d.bindings.surround_find_left,
                    highlight = vim.d.bindings.surround_highlight,
                    replace = vim.d.bindings.surround_replace,
                    suffix_last = vim.d.bindings.surround_suffix_last,
                    suffix_next = vim.d.bindings.surround_suffix_next,
                },
            }
        },
        neogit = {
            opts = {},
            setup = function(neogit)
                local bindings = vim.d.settings.bindings
                vim.keymap.set('n', bindings.neogit_status, neogit.open, {})
            end,
        },
        netrw = {
            opts = {
                icons = {
                    symlink = '',
                    directory = '',
                    file = '',
                },
                use_devicons = true,
                mappings = {
                    ['p'] = function(payload) print(vim.inspect(payload)) end,
                    ['<leader>p'] = ":echo 'hello world'<CR>",
                },
            },
            setup = function()

            end
        }
    }
}

return vim.d.settings
