return {
	-- Neovim TreeSitter
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup({
				ensure_installed = {
					'bash',
					'c',
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
			})
		end,
	},

	-- Markdown renderer
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
		ft = { 'markdown', 'quarto' },
		config = function()
			require('render-markdown').setup({
				completions = { lsp = { enabled = true } },
			})
		end,
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
		config = true,
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
	},

	-- Manage LSPs
	{
		'williamboman/mason.nvim',
		config = function()
			require('mason').setup({
				ui = {
					icons = {
						package_installed = '✓',
						package_pending = '➜',
					},
					border = 'rounded',
				},
			})
		end,
	},

	-- nnn File Explorer
	{
		'luukvbaal/nnn.nvim',
		config = function()
			require('nnn').setup()
		end,
	},

	--  Neovim statusline
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('lualine').setup({
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
			})
		end,
	},
}
