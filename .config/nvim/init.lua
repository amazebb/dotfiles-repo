require('config.configs')
require('config.keymaps')
require('config.autocmds')
require('custom.llm_chat')
require('config.lazy')

vim.lsp.enable({ 'lua_ls', 'bashls', 'basedpyright', 'gopls', 'ruff', 'yamlls' })
