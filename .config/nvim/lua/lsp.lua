-- LSP related settings
vim.g.lsp_enable_list = {
    "awk_ls",
    "basedpyright",
    "bashls",
    "cssls",
    "gopls",
    "html",
    "jdtls",
    "jsonls",
    "julials",
    "lua_ls",
    "ruff",
    "ts_ls",
    "yamlls",
}
vim.g.lsp_repo = "~/Code/GitHub/nvim-lspconfig"
vim.g.lsp_config = "~/.config/nvim/lsp"

-- All overrides of default nvim-lspconfig go after here
vim.lsp.config("bashls", {
    filetypes = { "bash", "sh", "zsh" },
    root_markers = { ".git", ".dotfiles" },
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
        },
    },
})

vim.lsp.config("ruff", {
    capabilities = {
        general = {
            -- get rid of pesky encode warning when running :checkhealth lsp
            positionEncodings = { "utf-16" },
        },
    },
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.completionProvider = false
    end,
})

vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard",
                autoSearchPaths = false,
                useLibraryCodeForTypes = false,
            },
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
        },
    },
})

vim.lsp.config("lua_ls", {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                -- library = {
                --     vim.env.VIMRUNTIME,
                --     -- Depending on the usage, you might want to add additional paths
                --     -- here.
                --     -- '${3rd}/luv/library'
                --     -- '${3rd}/busted/library'
                -- },
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
                -- The below library adds all plugins and de-dupes ~/.config files per the above GitHub
                library = vim.tbl_filter(function(d)
                    return not d:match(vim.fn.stdpath("config") .. "/?a?f?t?e?r?")
                end, vim.api.nvim_get_runtime_file("", true)),
            },
        })
    end,
    settings = {
        Lua = {},
    },
})

vim.lsp.enable(vim.g.lsp_enable_list)
vim.diagnostic.config({ virtual_text = true })
