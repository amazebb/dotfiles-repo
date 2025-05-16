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

    -- AI-powered coding
    {
        'olimorris/codecompanion.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter', 'ravitemer/mcphub.nvim' },
        opts = {
            extensions = {
                mcphub = {
                    callback = 'mcphub.extensions.codecompanion',
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true,
                    },
                },
            },
            strategies = {
                chat = {
                    adapter = 'xai',
                },
                inline = {
                    adapter = 'xai',
                },
                cmd = {
                    adapter = 'xai',
                },
            },
            opts = {
                -- Set debug logging
                log_level = 'DEBUG',
            },
            adapters = {
                mlx_lm = function()
                    return require('codecompanion.adapters').extend('openai_compatible', {
                        name = 'mlx_lm',
                        formatted_name = 'MLX LM',
                        env = {
                            url = 'http://localhost:8080', -- mlx-lm server endpoint
                        },
                        schema = {
                            model = {
                                default = 'mlx-community/Qwen3-4B-4bit', -- define llm model to be used
                                choices = {
                                    'mlx-community/Qwen3-8B-4bit',
                                    'mlx-community/Josiefied-Qwen3-1.7B-abliterated-v1-4bit',
                                },
                            },
                        },
                    })
                end,
                xai = function()
                    return require('codecompanion.adapters').extend('xai', {
                        env = {
                            api_key = 'cmd:security find-generic-password -s xai-api-key -w 2>/dev/null',
                        },
                        schema = {
                            ---@type CodeCompanion.Schema
                            model = {
                                order = 1,
                                mapping = 'parameters',
                                type = 'enum',
                                desc = 'ID of the model to use. See the model endpoint compatibility table for details on which models work with the Chat API.',
                                default = 'grok-3-beta',
                                choices = {
                                    'grok-3-beta',
                                    'grok-3-mini-beta',
                                    'grok-3-fast-beta',
                                    'grok-3-min-fast-beta',
                                },
                            },
                        },
                    })
                end,
            },
        },
    },

    -- MCP
    {
        'ravitemer/mcphub.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim', -- Required for Job and HTTP requests
        },
        opts = {},
        cmd = 'MCPHub', -- lazy load
        build = 'npm install -g mcp-hub@latest', -- Installs required mcp-hub npm module
        -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
        -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
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
