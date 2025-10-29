local opt = vim.opt

opt.cmdheight = 0
-- opt.colorcolumn = "80"
opt.completeopt = { "menuone", "popup", "noinsert" }
opt.cursorline = true
opt.expandtab = true
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftround = true
opt.shiftwidth = 4
opt.signcolumn = "yes:1"
opt.softtabstop = 4
opt.swapfile = false
opt.updatetime = 500
opt.winborder = "rounded"

vim.cmd.filetype("plugin indent on")
vim.g.python3_host_prog = "$HOME/.virtualenvs/py-nvim/.venv/bin/python3"

-- -- LSP related settings
-- vim.g.lsp_enable_list = {
--     "awk_ls",
--     "basedpyright",
--     "bashls",
--     "cssls",
--     "gopls",
--     "html",
--     "jdtls",
--     "jsonls",
--     "julials",
--     "lua_ls",
--     "ruff",
--     "ts_ls",
--     "yamlls",
-- }
-- vim.g.lsp_repo = "~/Code/GitHub/nvim-lspconfig"
-- vim.g.lsp_config = "~/.config/nvim/lsp"

vim.filetype.add({
    extension = {
        scpt = "applescript",
        applescript = "applescript",
        scptd = "applescript",
    },
})

vim.diagnostic.config({
    signs = true,
    virtual_text = true,
})

vim.api.nvim_set_hl(0, "CurrentTag", { underline = true, bold = true, standout = true })
vim.api.nvim_set_hl(0, "MatchParen", { standout = true })

if os.getenv("TERM") == "xterm-256color" then
    vim.api.nvim_set_hl(0, "CursorLineNr", { ctermfg = "Yellow" })
    vim.api.nvim_set_hl(0, "LineNr", { ctermbg = "DarkGray", ctermfg = "Black", bold = false })
    vim.api.nvim_set_hl(0, "NormalFloat", { ctermbg = "Black" })
    vim.api.nvim_set_hl(0, "PmenuSel", { fg = "white", bold = true, reverse = true })
    vim.api.nvim_set_hl(0, "Comment", { ctermfg = "DarkGray", italic = true })
else
    opt.termguicolors = true
end
