-- render markdown
_G.latex_enabled = true

return {
    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = { "rafamadriz/friendly-snippets" },

        -- use a release tag to download pre-built binaries
        version = "1.*",
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = "super-tab" },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = "mono",
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = { documentation = { auto_show = false } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
    {
        "junegunn/fzf.vim",
    },
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            buffers = {
                sort_lastused = false, -- this ensures buffers are sorted alphabetically
            },
        },
    },

    {
        "projekt0n/github-nvim-theme",
        name = "github-theme",
        lazy = false,
        config = function()
            if vim.env.TERM == "xterm-kitty" then
                vim.cmd("colorscheme github_dark")
            end
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "github_dark",
                component_separators = "|",
                section_separators = { left = "", right = "" },
            },

            sections = {
                lualine_c = {
                    {
                        function()
                            local excluded = { "codecompanion" }
                            if vim.tbl_contains(excluded, vim.bo.filetype) then
                                return ""
                            end
                            return vim.fn.expand("%:~")
                        end,
                    },
                },
            },
            tabline = {
                lualine_a = {
                    {
                        "buffers",
                        show_filename_only = true,
                        show_modified_status = true,
                        icons_enabled = false,
                        separator = "|",
                        symbols = { alternate_file = "", directory = "" },
                    },
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "master",
        build = ":TSUpdate",
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "awk",
                    "bash",
                    "c",
                    "fortran",
                    "lua",
                    "vim",
                    "vimdoc",
                    "markdown",
                    "markdown_inline",
                    "typescript",
                    "tsx",
                    "python",
                    "html",
                    "css",
                    "java",
                    "javascript",
                    "julia",
                    "query",
                    "sql",
                },
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                incremental_selection = { enable = true },
            })
        end,
    },
    {
        "cameron-wags/rainbow_csv.nvim",
        config = true,
        ft = {
            "csv",
            "tsv",
            "csv_semicolon",
            "csv_whitespace",
            "csv_pipe",
            "rfc_csv",
            "rfc_semicolon",
        },
        cmd = {
            "RainbowDelim",
            "RainbowDelimSimple",
            "RainbowDelimQuoted",
            "RainbowMultiDelim",
        },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        lazy = false,
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            completions = { lsp = { enabled = true } },
            code = { sign = false },
            file_types = { "markdown", "quarto", "codecompanion" },
        },
    },
}
