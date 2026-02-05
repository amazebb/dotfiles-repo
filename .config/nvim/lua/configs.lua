local opt = vim.opt

opt.cmdheight = 0
opt.completeopt = { "menuone", "popup", "noinsert", "preview" }
opt.cursorline = true
opt.cursorlineopt = "number"
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
opt.shortmess:append("I")
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevelstart = 99

vim.cmd.filetype("on")
vim.g.python3_host_prog = "$HOME/.config/nvim/py-nvim/.venv/bin/python3"
vim.g.enable_git_folder = true
vim.g.statusline_symbols = false

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
