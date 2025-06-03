return {
    -- Neovim TreeSitter
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'go',
                'html',
                'javascript',
                'latex',
                'lua',
                'markdown',
                'markdown_inline',
                'python',
                'sql',
                'vim',
                'vimdoc',
                'yaml',
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            ignore_install = {},
            modules = {},
            auto_install = true,
        },
    },

    -- Markdown renderer
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = { completions = { lsp = { enabled = true } } },
        ft = { 'markdown', 'quarto', 'codecompanion' },
    },

    -- fzf Neovim
    {
        'ibhagwan/fzf-lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {},
    },

    -- Debug Adapter Protocol client implementation for Neovim
    {
        'mfussenegger/nvim-dap',
    },

    -- Manage LSPs
    {
        'williamboman/mason.nvim',
        opts = {
            ui = {
                icons = {
                    package_installed = '✓',
                    package_pending = '➜',
                },
                border = 'rounded',
            },
        },
    },

    -- nnn File Explorer
    {
        'luukvbaal/nnn.nvim',
        opts = {},
    },

    --  Neovim statusline
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        opts = {
            options = {
                theme = 'solarized_dark',
                component_separators = '|',
                section_separators = { left = '', right = '' },
            },
            sections = {
                lualine_c = {
                    {
                        'filename',
                        path = 3,
                    },
                },
            },
            tabline = {
                lualine_a = {
                    {
                        'buffers',
                        show_filename_only = true,
                        show_modified_status = true,
                        icons_enabled = false,
                        separator = '|',
                        symbols = { alternate_file = '', directory = '' },
                    },
                },
            },
        },
    },
}
