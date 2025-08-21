vim.keymap.set("n", "H", function()
    local word = vim.fn.expand("<cWORD>")
    word = word:match("^[^%(%[{]+") or word
    local ok, _ = pcall(vim.cmd.help, word)
    if not ok then
        word = vim.fn.expand("<cword>")
    end
    vim.cmd("HelpPopup " .. word)
end, { desc = "Show Help in a floating window" })

-- Switch buffers
vim.keymap.set("n", "<C-n>", ":bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-p>", ":bprev<CR>", { desc = "Previous Buffer" })

-- FzfLua
vim.keymap.set("n", "<leader>b", ":FzfLua buffers<CR>", { desc = "Open buffers list using FzfLua", silent = true })
vim.keymap.set("n", "<leader>f", ":FzfLua<CR>", { desc = "Open FzfLua", silent = true })

-- Codecompanion AI
vim.keymap.set("n", "<leader>c", ":CodeCompanionChat Toggle<CR>", { desc = "CodeCompanionChat Toggle", silent = true })

-- Enable Copy/Paste and Select All
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { desc = "Copy to system clipboard", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-v>", '"+p', { desc = "Paste from system clipboard", noremap = true, silent = true })
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all text", noremap = true, silent = true })

-- Open a new terminal window in the bottom right corner
vim.keymap.set("n", "<leader>t", function()
    vim.cmd("belowright term")
    -- vim.fn.feedkeys blocking function is similar to non-block/async nvim_input
    vim.api.nvim_input("i")
end, { desc = "Terminal below right" })

-- Commenting
vim.keymap.set({ "n", "v" }, "<leader>/", "gc", { desc = "Toggle comment block", remap = true })
vim.keymap.set("n", "<leader>jj", "gcc", { desc = "Toggle comment lines", remap = true })

-- Close window
vim.keymap.set("n", "<C-q>", function()
    if vim.bo.buftype == "quickfix" then
        vim.cmd("cclose")
        vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
    else
        vim.cmd("bwipeout")
    end
end, { desc = "Close buffer in a more OS type way using Ctrl-q", silent = true })

-- Toggle line numbers between relative and absolute
vim.keymap.set("n", "<leader>l", function()
    vim.o.relativenumber = not vim.o.relativenumber
end, { desc = "Toggle relative/absolute line numbers" })

-- Goto next tag in help
vim.keymap.set("n", "]t", function()
    vim.fn.search("|.\\{-}|", "W")
    vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Next tag" })

-- Goto previous tag in help
vim.keymap.set("n", "[t", function()
    vim.fn.search("|\\k\\+|", "bW")
    vim.cmd("match CurrentTag /\\%#|.\\{-}|/")
end, { desc = "Prev tag" })

-- Show diagnostics under cursor in a float
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostics" })

-- Jump to next diagnostic
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

-- Jump to previous diagnostic
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

-- Show all diagnostics in a list (quickfix or location list)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

vim.keymap.set("n", "<C-i>", ":ShellCheckDisable<CR>", {
    desc = "Disable ShellCheck for current line",
    noremap = true,
    silent = true,
})

-- Toggle basedpyright type warnings
vim.keymap.set("n", "<leader>w", ":TogglePythonWarnings<CR>", { desc = "Toggle basedpyright warnings", silent = true })
