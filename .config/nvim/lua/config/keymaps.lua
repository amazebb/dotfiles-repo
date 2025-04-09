vim.keymap.set("n", "H", function()
	local word = vim.fn.expand("<cWORD>")
	word = word:match("^[^%(%[{]+") or word
	local ok, _ = pcall(vim.cmd, "help " .. word)
	if not ok then
		local cword = vim.fn.expand("<cword>")
		vim.cmd("help " .. cword)
	end
end, { desc = "Help with TOC" })

vim.keymap.set("n", "<C-n>", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-p>", ":bprev<CR>", { desc = "Previous Buffer" })

vim.keymap.set("n", "<leader>t", function()
	vim.cmd("belowright term")
	vim.fn.feedkeys("<C-\\><C-n>")
	vim.api.nvim_input("i")
end, { desc = "Term below right" })

vim.keymap.set({ "n", "v" }, "<leader>/", "gc", { desc = "Toggle comment block", remap = true })
vim.keymap.set("n", "<leader>jj", "gcc", { desc = "Toggle comment lines", remap = true })

vim.keymap.set("n", "<C-q>", function()
	if vim.bo.buftype == "quickfix" then
		vim.cmd("silent! cclose")
		vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
	else
		vim.cmd("silent! bwipeout")
	end
end, { desc = "Close buffer in a more OS type way using Ctrl-q", silent = true })

vim.keymap.set("n", "<leader>l", function()
	vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative/absolute line numbers" })

vim.keymap.set("n", "]t", function()
	vim.fn.search("|.\\{-}|", "W")
	vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Next tag" })

vim.keymap.set("n", "[t", function()
	vim.fn.search("|\\k\\+|", "bW")
	vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Prev tag" })

-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
-- vim.keymap.set("n", "<leader>rs", ":%s/\\<<C-r><C-w>\\>/gc", { desc = "Rename in file" })

-- Switch between colorschemes
local schemes = vim.fn.getcompletion("", "color")
local current = 1

local function show_popup(name, idx, total)
	local msg = string.format("Colorscheme: %s (%d/%d)", name, idx, total)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { msg })
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = #msg,
		height = 1,
		row = math.floor(vim.o.lines / 2),
		col = math.floor(vim.o.columns / 2 - #msg / 2),
		style = "minimal",
		border = "single",
	})
	vim.defer_fn(function()
		vim.api.nvim_win_close(win, true)
	end, 1000)
end

vim.keymap.set("n", "]c", function()
	current = (current % #schemes) + 1
	vim.cmd("colorscheme " .. schemes[current])
	show_popup(schemes[current], current, #schemes)
end, { desc = "Next colorscheme" })

vim.keymap.set("n", "[c", function()
	current = (current - 2) % #schemes + 1
	vim.cmd("colorscheme " .. schemes[current])
	show_popup(schemes[current], current, #schemes)
end, { desc = "Prev colorscheme" })

-- Show diagnostics under cursor in a float
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics" })

-- Jump to next diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Jump to previous diagnostic
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- Show all diagnostics in a list (quickfix or location list)
--vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })
vim.keymap.set("n", "<leader>q", function()
	local diags = vim.diagnostic.get(0) -- Current buffer diagnostics
	local items = {}
	for _, diag in ipairs(diags) do
		local sev = ({ "E", "W", "I", "H" })[diag.severity] -- E=Error, W=Warn, I=Info, H=Hint
		local msg = diag.message:match("^[^\n]+") -- First line only
		table.insert(items, {
			lnum = diag.lnum + 1, -- 1-based line number
			col = diag.col + 1, -- 1-based column
			text = string.format("%s %d %s", sev, diag.lnum + 1, msg),
		})
	end
	vim.fn.setloclist(0, items, "r") -- Replace loclist
	vim.cmd("lopen") -- Open it
end, { desc = "Diagnostics list" })
