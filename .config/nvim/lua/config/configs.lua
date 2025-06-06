vim.g.mapleader = ' '
vim.g.python3_host_prog = '~/.config/nvim/rplugin/python3/.venv/bin/python3'

vim.g.markdown_fenced_languages =
    { 'python', 'bash=sh', 'javascript', 'html', 'css', 'lua', 'matlab', 'java', 'c', 'gitcommit', 'sql', 'diff' }
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.laststatus = 0
vim.o.cmdheight = 0
vim.o.winborder = 'rounded'
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.updatetime = 500
vim.o.signcolumn = 'auto'
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

vim.diagnostic.config({
    signs = true,
    virtual_text = true,
})

vim.api.nvim_set_hl(0, 'CurrentTag', { underline = true, bold = true, standout = true })
vim.api.nvim_set_hl(0, 'MatchParen', { standout = true })

if os.getenv('TERM') == 'xterm-256color' then
    vim.api.nvim_set_hl(0, 'CursorLineNr', { ctermfg = 'Yellow' })
    vim.api.nvim_set_hl(0, 'LineNr', { ctermbg = 'DarkGray', ctermfg = 'Black', bold = false })
    vim.api.nvim_set_hl(0, 'NormalFloat', { ctermbg = 'Black' })
    vim.api.nvim_set_hl(0, 'PmenuSel', { fg = 'white', bold = true, reverse = true })
    vim.api.nvim_set_hl(0, 'Comment', { ctermfg = 'DarkGray', italic = true })
else
    vim.opt.termguicolors = true
end

-- yank to the clipboard automatically
vim.opt.clipboard:append('unnamedplus')
