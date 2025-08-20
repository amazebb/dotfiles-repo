return {
    {
        'vim-scripts/applescript.vim',
        ft = 'applescript', -- Load only for AppleScript files
    },

    {
        'neovim/nvim-lspconfig',
        init = function()
            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        analysis = {
                            typeCheckingMode = 'standard',
                        },

                        -- Using Ruff's import organizer
                        disableOrganizeImports = true,
                    },
                },
            })
            vim.lsp.config('ruff', {
                capabilities = {
                    general = {
                        -- get rid of pesky encode warning when running :checkhealth lsp
                        positionEncodings = { 'utf-16' },
                    },
                },
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                    client.server_capabilities.completionProvider = false
                end,
            })
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most
                            -- likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Tell the language server how to find Lua modules same way as Neovim
                            -- (see `:h lua-module-load`)
                            path = {
                                'lua/?.lua',
                                'lua/?/init.lua',
                            },
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME,
                                -- Add Lazy managed plugins
                                vim.fn.stdpath('data') .. '/lazy',
                                '${3rd}/luv/library',
                            },
                        },
                    },
                },
            })
            vim.lsp.config('bashls', {
                root_markers = { '.git', '.sh' },
                filetypes = { 'bash', 'sh', 'zsh' },
                settings = {
                    bashIde = {
                        -- Default upstream pattern is '**/*@(.sh|.inc|.bash|.command)'.
                        globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command|.zsh)',
                    },
                },
            })
        end,
    },
    {
        '3rd/image.nvim',
        build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            processor = 'magick_cli',
        },
    },
}
