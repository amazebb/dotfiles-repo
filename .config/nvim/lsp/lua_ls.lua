return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_dir = vim.fs.dirname(vim.fs.find({ ".luarc.json", ".luarc.jsonc" }, { upward = true })[1]) or vim.fn.getcwd(),
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = { globals = { "vim" } },
		},
	},
}
