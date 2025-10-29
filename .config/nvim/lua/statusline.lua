-- Default statusline in 0.12
--
-- %<%f %h%w%m%r                                        " Left: file info (path, help, preview, modified, readonly)
-- %=                                                   " Separator: right-align following items
-- %{% &showcmdloc == 'statusline' ? '%-10.S ' : '' %}  " Showcmd: partial command if showcmdloc=statusline
-- %{% exists('b:keymap_name') ? '<'..b:keymap_name..'> ' : '' %}       " Keymap: buffer keymap name if set
-- %{% &busy > 0 ? '◐ ' : '' %}                                         " Busy: indicator during long operations
-- %(%{luaeval('(package.loaded['' vim.diagnostic''] and vim.diagnostic.status()) or '''' ')} %)    " Diagnostics: status string if module loaded, group omits if empty
-- %{% &ruler ? ( &rulerformat == '' ? '%-14.(%l,%c%V%) %P' : &rulerformat ) : '' %}                " Ruler: line/col/percent or custom rulerformat if enabled
--
--
Statusline = {}

-- Mode map: short → full name
local mode_map = {
    n = "NORMAL",
    no = "O-PENDING",
    -- v = 'V-BLOCK',
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    R = "REPLACE",
    Rc = "REPLACE",
    Rx = "REPLACE",
    c = "COMMAND",
    cv = "EX",
    r = "PROMPT",
    rm = "MORE",
    -- r? = 'CONFIRM',
    -- ! = 'SHELL',
    t = "TERMINAL",
}

function Statusline.active()
    local mode = vim.fn.mode()
    return "[" .. (mode_map[mode] or mode) .. "] %f%m%=%y [%P %l:%c]"
end

function Statusline.inactive()
    return " %t"
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = group,
    desc = "Activate statusline on focus",
    callback = function()
        vim.opt_local.statusline = "%!v:lua.Statusline.active()"
    end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = group,
    desc = "Deactivate statusline when unfocused",
    callback = function()
        vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
    end,
})
