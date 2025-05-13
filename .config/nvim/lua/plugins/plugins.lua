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
		ft = { 'markdown', 'quarto' },
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
			adapters = {
				xai = function()
					return require('codecompanion.adapters').extend('xai', {
						env = {
							api_key = 'cmd:security find-generic-password -s xai-api-key -w 2>/dev/null',
						},
					})
				end,
			},
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
