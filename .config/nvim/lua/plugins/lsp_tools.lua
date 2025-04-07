return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"awk_ls",
					"bashls",
					"clangd",
					"cssls",
					"html",
					"jdtls",
					"jsonls",
					"lua_ls",
					"matlab_ls",
					"basedpyright",
					"pylsp",
					"ruff",
					"ts_ls",
					"yamlls",
				},
			})
		end,
	},
}
