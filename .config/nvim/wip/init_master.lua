-- Recommended to make NvimTree work correctly
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.mapleader = " "
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.laststatus = 0
vim.o.cmdheight = 0 -- Hide command line by default

-- Line Numbers Display
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true -- Highlight current line
vim.o.cursorlineopt = "number" -- Only highlight the line number, not the whole line
vim.api.nvim_set_hl(0, "CursorLineNr", { ctermfg = 11 })
vim.api.nvim_set_hl(0, "LineNr", { ctermbg = "DarkGray", ctermfg = "Black", bold = false })

-- Matching braces and parenthesis
vim.api.nvim_set_hl(0, "MatchParen", { standout = true })

-- Change floating background so we can see Lazy and Mason better
vim.api.nvim_set_hl(0, "NormalFloat", { ctermbg = "Black" })

local function open_help_toc()
	local word = vim.fn.expand("<cWORD>") -- e.g., "vim.api"
	word = word:match("^[^%(%[{]+") or word -- Trim to vim.api from vim.api(
	local ok, _ = pcall(vim.cmd, "help " .. word) -- Try exact
	if not ok then
		local cword = vim.fn.expand("<cword>")
		vim.cmd("help " .. cword)
	end
end

local function cycle_buffers(direction)
	local bt = vim.bo[vim.api.nvim_get_current_buf()].buftype
	if bt == "help" then
		vim.cmd("wincmd j") -- Down to TOC
	elseif bt == "quickfix" then
		vim.cmd("wincmd k") -- Up to help
	elseif bt == "" then
		local current = vim.fn.bufnr()
		vim.cmd(direction)
		local next_bt = vim.bo[vim.fn.bufnr()].buftype
		local next_ft = vim.bo[vim.fn.bufnr()].filetype
		while (next_bt == "quickfix" or next_ft == "qf") and vim.fn.bufnr() ~= current do
			vim.cmd(direction) -- Skip quickfix/qf buffers
			next_bt = vim.bo[vim.fn.bufnr()].buftype
			next_ft = vim.bo[vim.fn.bufnr()].filetype
		end
	end
end

-- Help config
vim.keymap.set("n", "H", open_help_toc, { desc = "Help with TOC" })
vim.keymap.set("n", "<C-n>", function()
	cycle_buffers("bnext")
end, { desc = "Next" })
vim.keymap.set("n", "<C-p>", function()
	cycle_buffers("bprev")
end, { desc = "Previous" })

-- Open terminal at the bottom
vim.keymap.set("n", "<leader>t", function()
	vim.cmd("belowright term")
	vim.fn.feedkeys("<C-\\><C-n>")
	vim.api.nvim_input("i")
end, { desc = "Term below" })

-- Commenting blocks of code
-- This was mentioned in a comment here https://github.com/neovim/neovim/discussions/29075
-- Grok was having a hell of a time not able to work it out
vim.keymap.set({ "n", "v" }, "<leader>/", "gc", { desc = "Toggle comment block", remap = true })
vim.keymap.set("n", "<leader>jj", "gcc", { desc = "Toggle comment n lines", remap = true }) -- 10<Space>jj comments below 10 lines
vim.api.nvim_set_hl(0, "Comment", {
	ctermfg = "DarkGray",
	italic = true,
})

-- Close buffer without displaying commands into command line and leaving it hanging
vim.keymap.set("n", "<C-q>", function()
	if vim.bo.buftype == "quickfix" then
		vim.cmd("silent! cclose") -- Close TOC window
		vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
	elseif vim.bo.filetype == "lspinfo" then
		vim.cmd("silent! close") -- Close LSP window
	else
		vim.cmd("silent! bwipeout") -- Close TOC window
	end
end, { desc = "Close buffer and switch to previous", silent = true })

-- Toggle line numbers from relative to absolute
vim.keymap.set("n", "<leader>l", function()
	if vim.o.relativenumber then
		vim.o.relativenumber = false
		vim.o.number = true
	else
		vim.o.relativenumber = true
		vim.o.number = true
	end
end, { desc = "Toggle relative/absolute line numbers" })

-- Map ]t and [t to jump between |tag| markers in help
-- Define a highlight group for the current tag
vim.api.nvim_set_hl(0, "CurrentTag", { underline = true, bold = true, standout = true })
vim.keymap.set("n", "]t", function()
	vim.fn.search("|.\\{-}|", "W") -- Next tag
	vim.cmd("match CurrentTag /\\%#|.\\{-}|/") -- Highlight tag under cursor
end, { desc = "Next tag" })
vim.keymap.set("n", "[t", function()
	vim.fn.search("|\\k\\+|", "bW") -- Prev tag
	vim.cmd("match CurrentTag /\\%#|.\\{-}|/") -- Highlight tag under cursor
end, { desc = "Prev tag" })

-- Show cmdline when entering, hide when leaving
vim.api.nvim_create_autocmd("CmdlineEnter", {
	callback = function()
		vim.o.cmdheight = 1
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		vim.o.cmdheight = 0
	end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Autocomplete plugins
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"rafamadriz/friendly-snippets",
	"saadparwaiz1/cmp_luasnip",

	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
	},

	-- LSP and tools
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lspconfig").html.setup({
				cmd = { "vscode-html-language-server", "--stdio" },
				autostart = true,
			})
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- This will provide type hinting with LuaLS
		---@module "conform"
		-- ---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				sh = { "shfmt" },
				bash = { "shfmt" },
				lua = { "stylua" },
				python = { "black" },
				typescript = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
			},
			-- Set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
	},

	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",

	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- AI
	{
		"olimorris/codecompanion.nvim",
		config = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
	},

	-- Your original plugins
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	"folke/neodev.nvim",
}, {
	-- Optional global options (e.g., disable LuaRocks)
	rocks = { enabled = false },
})

-- LSP setup
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"clangd",
		"cssls",
		"html",
		"jdtls",
		"jsonls",
		"lua_ls",
		"matlab_ls",
		"pylsp",
		"yamlls",
		"ts_ls",
	},
})

local cmp = require("cmp")
local luasnip = require("luasnip")

-- Auto-complete menu and popup, nvim-cmp setup
cmp.setup({
	window = {
		completion = {
			border = "rounded",
		},
		documentation = {
			border = "rounded",
		},
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body) -- Expand snippets with LuaSnip
		end,
	},
	sources = {
		{ name = "nvim_lsp" }, -- Smart completions from LSP
		{ name = "buffer" }, -- Words from current buffer
		{ name = "path" }, -- File paths (great for Bash/SH)
		{ name = "cmdline" },
		{ name = "luasnip" }, -- Snippets (e.g., HTML tags, JS functions)
	},
	mapping = {
		["<Tab>"] = cmp.mapping.select_next_item(), -- Next suggestion
		["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Previous
		["<kDown>"] = cmp.mapping.select_next_item(), -- Down arrow raw
		["<kUp>"] = cmp.mapping.select_prev_item(), -- Up arrow raw
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept
		["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion
	},
})

-- Command-line completion for `:`
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "path" }, -- File paths
		{ name = "cmdline" }, -- Vim commands
	},
})

-- Search completion for `/` and `?`
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" }, -- Buffer words
	},
})

require("lualine").setup({
	options = {
		theme = "solarized_dark",
		component_separators = "|",
		section_separators = { left = "", right = "" },
	},
	tabline = {
		lualine_a = {
			{
				"buffers",
				cond = function()
					local buf_name = vim.api.nvim_buf_get_name(0)
					return not buf_name:match("NvimTree")
				end,
				show_filename_only = true, -- Just filename, no path
				show_modified_status = true, -- Show * for unsaved
				icons_enabled = false, -- Dont display file icons in buffer
				separator = "|",
				symbols = {
					alternate_file = "", -- Text to show to identify the alternate file
					directory = "", -- No dir prefix
				},
			},
		}, -- Show open buffers as tabs
	},
})

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.pylsp.setup({ capabilities = capabilities }) -- Python
lspconfig.bashls.setup({ capabilities = capabilities }) -- Shell
lspconfig.clangd.setup({ capabilities = capabilities }) -- C/C++
lspconfig.cssls.setup({ capabilities = capabilities }) -- CSS
lspconfig.html.setup({ capabilities = capabilities }) -- HTML
lspconfig.jdtls.setup({ capabilities = capabilities }) -- Java
lspconfig.jsonls.setup({ capabilities = capabilities }) -- JSON
lspconfig.matlab_ls.setup({ capabilities = capabilities }) -- Matlab
lspconfig.yamlls.setup({ capabilities = capabilities }) -- YAML
lspconfig.ts_ls.setup({ capabilities = capabilities }) -- JS/TS
lspconfig.lua_ls.setup({
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	settings = {
		Lua = {
			format = {
				enable = true, -- Ensure formatting is on
				defaultConfig = {
					indent_style = "space", -- Use spaces, not tabs
					indent_size = "2", -- 2-space indents
				},
			},
			diagnostics = {
				globals = { "vim" }, -- Suppress 'undefined vim' warnings
			},
		},
	},
})

lspconfig.ts_ls.setup({
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

lspconfig.html.setup({
	autostart = true,
	-- on_attach = your_on_attach or function() end,
	cmd = { "vscode-html-language-server", "--stdio" }, -- Mason’s binary
	settings = {}, -- Whatever you need
	-- Force stop when no buffers need it
	on_exit = function()
		vim.schedule(function()
			local clients = vim.lsp.get_active_clients({ name = "html" })
			if #clients > 0 and not vim.lsp.buf_is_attached(0, clients[1].id) then
				clients[1].stop()
			end
		end)
	end,
})

require("nvim-tree").setup()

-- Menu popup style setup, place after cmp.setup
vim.api.nvim_set_hl(0, "Pmenu", { bg = "#282828", fg = "#ebdbb2" }) -- Dark gray bg, light fg
vim.api.nvim_set_hl(0, "PmenuSel", { fg = "white", bold = true, reverse = true }) -- Blue bg, white fg, bold
vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#3c3836" }) -- Scrollbar
vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#a89984" }) -- Scrollbar thumb

-- Kill LSP when buffer closes and no other buffers need the LSP
vim.api.nvim_create_autocmd("BufDelete", {
	pattern = "*", -- Catch all filetypes
	callback = function(args)
		local buf = args.buf -- Buffer being deleted
		-- Get LSP clients attached to this buffer
		local clients = vim.lsp.get_active_clients({ bufnr = buf })
		if #clients == 0 then
			return
		end -- No LSP, nothing to do

		for _, client in pairs(clients) do
			-- Check if any other loaded buffers use this LSP
			local has_buffers = false
			for _, other_buf in pairs(vim.api.nvim_list_bufs()) do
				if other_buf ~= buf and vim.api.nvim_buf_is_loaded(other_buf) then
					if vim.lsp.buf_is_attached(other_buf, client.id) then
						has_buffers = true
						break
					end
				end
			end

			-- No other buffers need this LSP? Stop it
			if not has_buffers then
				client.stop(true)
			end
		end
	end,
})

-- Show a popup hint for matching braces that are off screen
vim.api.nvim_create_autocmd("CursorMoved", {
	pattern = "*",
	callback = function()
		-- Get cursor pos, only need col
		local cur_pos = vim.api.nvim_win_get_cursor(0)
		local col = cur_pos[2]
		local char = vim.api.nvim_get_current_line():sub(col + 1, col + 1)
		if not char:match("[%(%){%[%]%)]") then
			return
		end

		-- Jump to match, get pos, return
		vim.cmd("normal! %")
		local match_pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_win_set_cursor(0, cur_pos)

		-- Check if off-screen
		local match_line = match_pos[1]
		local top = vim.fn.line("w0")
		local bottom = vim.fn.line("w$")
		if match_line >= top and match_line <= bottom then
			return
		end

		-- Popup
		local msg = "Match at line " .. match_line .. ": " .. vim.fn.getline(match_line)
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })
		local opts = {
			relative = "cursor",
			row = 1,
			col = 1,
			width = #msg + 2,
			height = 1,
			style = "minimal",
			border = "single",
		}
		local win = vim.api.nvim_open_win(buf, false, opts)
		vim.defer_fn(function()
			vim.api.nvim_win_close(win, true)
		end, 1500)
	end,
})

-- Show the help to the right in a vertical split
-- BufWinEnter: Fires when a buffer enters a window
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.buftype == "help" then
			vim.cmd("wincmd L") -- Right vertical split
			vim.api.nvim_input("gO") -- Execute gO
			vim.wo.wrap = false
		elseif vim.bo.buftype == "quickfix" then -- Targets TOC window
			vim.wo.wrap = false -- No wrapping in TOC
		end
	end,
})

-- Highlight the selected file in NvimTree
vim.api.nvim_set_hl(0, "NvimTreeCursorLine", {
	reverse = true, -- Reverse bg/fg for cursor line
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "NvimTree",
	callback = function()
		vim.opt_local.cursorline = true -- Enable cursorline
		vim.opt_local.winhighlight = "CursorLine:NvimTreeCursorLine" -- Link to custom highlight
		vim.opt_local.fillchars = vim.opt_local.fillchars + "eob: " -- Hide ~ with space
		-- Force it after render
		vim.defer_fn(function()
			vim.opt_local.fillchars = vim.opt_local.fillchars + "eob: "
		end, 50) -- 50ms delay
	end,
})
