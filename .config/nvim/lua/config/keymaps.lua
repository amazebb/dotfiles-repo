-- Help on word under cursor
vim.keymap.set('n', 'H', function()
	local word = vim.fn.expand('<cWORD>')
	word = word:match('^[^%(%[{]+') or word
	local ok, _ = pcall(vim.cmd.help, word)
	if not ok then
		local cword = vim.fn.expand('<cword>')
		vim.cmd('HelpPopup ' .. cword)
	end
end, { desc = 'Help with TOC' })

vim.keymap.set('n', '<leader>h', ':HelpPopup<cr>', { noremap = true, silent = true })

-- Switch buffers
vim.keymap.set('n', '<C-n>', ':bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<C-p>', ':bprev<CR>', { desc = 'Previous Buffer' })

-- Open FzfLua buffers
vim.keymap.set('n', '<leader>b', ':FzfLua buffers<CR>', { desc = 'Open buffers list using FzfLua', silent = true })

-- Enable Copy/Paste and Slect All
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { noremap = true, silent = true, desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-v>', '"+p', { noremap = true, silent = true, desc = 'Paste from system clipboard' })
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true, silent = true, desc = 'Select all text' })

-- Open a new terminal window in the bottom right corner
vim.keymap.set('n', '<leader>t', function()
	vim.cmd('belowright term')
	vim.fn.feedkeys('<C-\\><C-n>')
	vim.api.nvim_input('i')
end, { desc = 'Terminal below right' })

-- Commenting
vim.keymap.set({ 'n', 'v' }, '<leader>/', 'gc', { desc = 'Toggle comment block', remap = true })
vim.keymap.set('n', '<leader>jj', 'gcc', { desc = 'Toggle comment lines', remap = true })

-- Close window
vim.keymap.set('n', '<C-q>', function()
	if vim.bo.buftype == 'quickfix' then
		vim.cmd('cclose')
		vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
	else
		vim.cmd('bwipeout')
	end
end, { desc = 'Close buffer in a more OS type way using Ctrl-q', silent = true })

-- Toggle line numbers between relative and absolute
vim.keymap.set('n', '<leader>l', function()
	vim.o.relativenumber = not vim.o.relativenumber
end, { desc = 'Toggle relative/absolute line numbers' })

-- Goto next tag in help
vim.keymap.set('n', ']t', function()
	vim.fn.search('|.\\{-}|', 'W')
	vim.cmd('match CurrentTag /\\%#|.\\{-}|/')
end, { desc = 'Next tag' })

-- Goto previous tag in help
vim.keymap.set('n', '[t', function()
	vim.fn.search('|\\k\\+|', 'bW')
	vim.cmd('match CurrentTag /\\%#|.\\{-}|/')
end, { desc = 'Prev tag' })

-- vim.keymap.set("n", "<leader>rs", ":%s/\\<<C-r><C-w>\\>/gc", { desc = "Rename in file" })

-- Show diagnostics under cursor in a float
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostics' })

-- Jump to next diagnostic
vim.keymap.set('n', ']d', function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })

-- Jump to previous diagnostic
vim.keymap.set('n', '[d', function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Prev diagnostic' })

-- Show all diagnostics in a list (quickfix or location list)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics list' })

-- Function to insert ShellCheck disable directive for warning under cursor
local function insert_shellcheck_disable()
	local line = vim.fn.line('.') - 1
	local diagnostics = vim.diagnostic.get(0, { lnum = line })
	for _, diag in ipairs(diagnostics) do
		if diag.source == 'shellcheck' and diag.code then
			local code = string.match(diag.code, 'SC%d+') or diag.code
			vim.api.nvim_buf_set_lines(0, line, line, false, { '# shellcheck disable=' .. code })
			return
		end
	end
	vim.notify('No ShellCheck warning found under cursor', vim.log.levels.WARN)
end

--  Disbale ShellCheck for current line
vim.keymap.set('n', '<C-i>', insert_shellcheck_disable, { noremap = true, silent = true })

-- Toggle basedpyright type warnings
vim.keymap.set(
	'n',
	'<leader>w',
	':TogglePythonWarnings<CR>',
	{ desc = 'Toggle basedpyright warnings between standard and recommended', silent = true }
)
