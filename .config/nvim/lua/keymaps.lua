vim.g.mapleader = " "
local keymap = vim.keymap.set

keymap("n", "H", function()
    local word = vim.fn.expand("<cWORD>")
    word = word:match("^[^%(%[{]+") or word
    local ok, _ = pcall(vim.cmd.help, word)
    if not ok then
        word = vim.fn.expand("<cword>")
    end
    vim.cmd("HelpPopup " .. word)
end, { desc = "Show Help in a floating window" })

-- Check for plugins
keymap("n", "<Leader>p", vim.pack.update, { desc = "Check for Plugins" })

-- Download latest LSP config settings from nvim-lspconfig
local fun = require("functions")
keymap("n", "<Leader>s", fun.update_lspconfigs, { desc = "Update LSP configs" })

-- Switch buffers
keymap("n", "<C-n>", ":bnext<CR>", { desc = "Next Buffer" })
keymap("n", "<C-p>", ":bprev<CR>", { desc = "Previous Buffer" })

-- FzfLua
keymap("n", "<Leader>b", ":FzfLua buffers<CR>", { desc = "Open buffers list using FzfLua", silent = true })
keymap("n", "<Leader>f", ":FzfLua<CR>", { desc = "Open FzfLua", silent = true })

-- Codecompanion AI
keymap("n", "<Leader>c", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanionChat Toggle", silent = true })

-- Enable Copy/Paste and Select All
keymap({ "n", "v" }, "<C-c>", '"+y', { desc = "Copy to system clipboard", noremap = true, silent = true })
keymap({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from system clipboard", noremap = true, silent = true })
keymap("n", "<C-a>", "ggVG", { desc = "Select all text", noremap = true, silent = true })

-- Open a new terminal window in the bottom right corner
keymap("n", "<Leader>t", function()
    vim.cmd("belowright term")
    -- vim.fn.feedkeys blocking is similar to non-block/async nvim_input
    vim.api.nvim_input("i")
end, { desc = "Terminal below right" })

-- Commenting
keymap({ "n", "v" }, "<Leader>/", "gc", { desc = "Toggle comment block", remap = true })
keymap("n", "<Leader>jj", "gcc", { desc = "Toggle comment lines", remap = true })

-- Close window
keymap("n", "<C-q>", function()
    if vim.bo.buftype == "quickfix" then
        vim.cmd("cclose")
        vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
    else
        vim.cmd("bwipeout")
    end
end, { desc = "Close buffer in a more OS type way using Ctrl-q", silent = true })

-- Toggle line numbers between relative and absolute
keymap("n", "<Leader>l", function()
    vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative/absolute line numbers" })

-- Goto next tag in help
keymap("n", "]t", function()
    vim.fn.search("|.\\{-}|", "W")
    vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Next tag" })

-- Goto previous tag in help
keymap("n", "[t", function()
    vim.fn.search("|\\k\\+|", "bW")
    vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Prev tag" })

-- Show diagnostics under cursor in a float
keymap("n", "<Leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics" })

-- Jump to next diagnostic
keymap("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Jump to previous diagnostic
keymap("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

-- Show all diagnostics in a list (quickfix or location list)
keymap("n", "<Leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

keymap("n", "<C-i>", ":ShellCheckDisable<CR>", {
    desc = "Disable ShellCheck for current line",
    noremap = true,
    silent = true,
})

-- Toggle basedpyright type warnings
keymap("n", "<Leader>w", ":TogglePythonWarnings<CR>", { desc = "Toggle basedpyright warnings", silent = true })

-- Splitting windows
keymap("n", "<Leader>_", "<cmd>vsplit<CR>", { silent = true })
keymap("n", "<Leader>-", "<cmd>split<CR>", { silent = true })

-- Launch Quicklook preview for current file, useful for previewing markdown
vim.keymap.set('n', '<Leader><Leader>', function()
    local file = vim.fn.expand('%:p')
    vim.fn.system(string.format('qlmanage -p %s 2>/dev/null', vim.fn.shellescape(file)))
end, { desc = 'QuickLook file preview)' })
