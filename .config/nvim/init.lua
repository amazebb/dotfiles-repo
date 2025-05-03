require("config.configs")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")


vim.lsp.enable({ "lua_ls", "bashls", "basedpyright", "ruff", "matlab", "yamlls" })
