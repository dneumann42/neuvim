vim.d.bindings = {
    eval_buffer = "<C-c>b",

    telescope_find_file = "<leader>f",
    telescope_find_buffer = "<leader>b",
    telescope_live_grep = "<leader>g",
    telescope_help = "<leader>h",

    neo_tree_toggle = "<M-0>",
    toggle_terminal = "<c-space>",
    neogit_status   = "<space>G",

    surround_add = "sa",
    surround_delete = "sd",
    surround_find = "sf",
    surround_find_left = "sF",
    surround_highlight = "sh",
    surround_replace = "cs",
    surround_suffix_last = "l",
    surround_suffix_next = "n",
}

vim.d.settings = {
    tab_size = 4,
    mapleader = ",",
    auto_session_path = ".local/share/nvim/auto-session.vim",
    color_scheme = "koehler",

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
        ['mini.indentscope'] = {
            opts = {
                symbol = '│',
                draw = {
                    delay = 0,
                }
            },
            setup = function(identscope)
                identscope.gen_animation.none()
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
        }
    }
}

return vim.d.settings
