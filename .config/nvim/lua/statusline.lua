Statusline = {}

-- Mode map: short → full name
local mode_map = {
    n = "NORMAL",            -- Normal
    no = "O-PENDING",        -- Operator-pending
    nov = "O-PENDING",       -- Operator-pending (forced charwise |o_v|)
    noV = "O-PENDING",       -- Operator-pending (forced linewise |o_V|)
    ["no\22"] = "O-PENDING", -- Operator-pending (forced blockwise |o_CTRL-V|)
    niI = "NORMAL",          -- Normal using |i_CTRL-O| in |Insert-mode|
    niR = "NORMAL",          -- Normal using |i_CTRL-O| in |Replace-mode|
    niV = "NORMAL",          -- Normal using |i_CTRL-O| in |Virtual-Replace-mode|
    nt = "NORMAL",           -- Normal in |terminal-emulator| (insert goes to Terminal mode)
    ntT = "NORMAL",          -- Normal using |t_CTRL-\_CTRL-O| in |Terminal-mode|
    v = "VISUAL",            -- Visual by character
    vs = "VISUAL",           -- Visual by character using |v_CTRL-O| in Select mode
    V = "V-LINE",            -- Visual by line
    Vs = "V-LINE",           -- Visual by line using |v_CTRL-O| in Select mode
    ["\22"] = "V-BLOCK",     -- Visual blockwise
    ["\22s"] = "V-BLOCK",    -- Visual blockwise using |v_CTRL-O| in Select mode
    s = "SELECT",            -- Select by character
    S = "S-LINE",            -- Select by line
    ["\19"] = "S-BLOCK",     -- Select blockwise
    i = "INSERT",            -- Insert
    ic = "INSERT",           -- Insert mode completion |compl-generic|
    ix = "INSERT",           -- Insert mode |i_CTRL-X| completion
    R = "REPLACE",           -- Replace |R|
    Rc = "REPLACE",          -- Replace mode completion |compl-generic|
    Rx = "REPLACE",          -- Replace mode |i_CTRL-X| completion
    Rv = "V-REPLACE",        -- Virtual Replace |gR|
    Rvc = "V-REPLACE",       -- Virtual Replace mode completion |compl-generic|
    Rvx = "V-REPLACE",       -- Virtual Replace mode |i_CTRL-X| completion
    c = "COMMAND",           -- Command-line editing
    cr = "COMMAND",          -- Command-line editing overstrike mode |c_<Insert>|
    cv = "EX",               -- Vim Ex mode |gQ|
    cvr = "EX",              -- Vim Ex mode while in overstrike mode |c_<Insert>|
    r = "PROMPT",            -- Hit-enter prompt
    rm = "MORE",             -- The -- more -- prompt
    ["r?"] = "CONFIRM",      -- A |:confirm| query of some sort
    ["!"] = "SHELL",         -- Shell or external command is executing
    t = "TERMINAL",          -- Terminal mode: keys go to the job
}

function Statusline.active(branch)
    local mode = vim.fn.mode()
    return "[" .. (mode_map[mode] or mode) .. "] " .. branch .. " %f%m%=%y [%P %l:%c]"
end

function Statusline.inactive()
    return " %t"
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
    desc = "Activate statusline on focus",
    callback = function()
        local file_dir = vim.fn.expand("%:p:h")
        local branch =
            vim.fn.system("git-wrapper -C " .. file_dir .. " rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
        vim.opt_local.statusline = '%!v:lua.Statusline.active("' .. branch .. '")'
    end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = group,
    desc = "Deactivate statusline when unfocused",
    callback = function()
        vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
    end,
})
