Statusline = {}

vim.api.nvim_set_hl(0, 'User1', { fg = '#000000' })
vim.api.nvim_set_hl(0, 'User2', { fg = '#FFFF00' })
vim.api.nvim_set_hl(0, 'User3', { fg = '#8B0000' })
vim.api.nvim_set_hl(0, 'User4', { fg = '#006400' })
vim.api.nvim_set_hl(0, 'User5', { fg = '#0000FF' })
vim.api.nvim_set_hl(0, 'User6', { fg = '#8B4500' })
vim.api.nvim_set_hl(0, 'User7', { fg = '#2FFF4F' })

-- Mode map: short → full name
local mode_map = {
    n = { "NORMAL", "1" },            -- Normal
    no = { "O-PENDING", "3" },        -- Operator-pending
    nov = { "O-PENDING", "3" },       -- Operator-pending (forced charwise |o_v|)
    noV = { "O-PENDING", "3" },       -- Operator-pending (forced linewise |o_V|)
    ["no\22"] = { "O-PENDING", "3" }, -- Operator-pending (forced blockwise |o_CTRL-V|)
    niI = { "NORMAL", "1" },          -- Normal using |i_CTRL-O| in |Insert-mode|
    niR = { "NORMAL", "1" },          -- Normal using |i_CTRL-O| in |Replace-mode|
    niV = { "NORMAL", "1" },          -- Normal using |i_CTRL-O| in |Virtual-Replace-mode|
    nt = { "NORMAL", "1" },           -- Normal in |terminal-emulator| (insert goes to Terminal mode)
    ntT = { "NORMAL", "1" },          -- Normal using |t_CTRL-\_CTRL-O| in |Terminal-mode|
    v = { "VISUAL", "4" },            -- Visual by character
    vs = { "VISUAL", "4" },           -- Visual by character using |v_CTRL-O| in Select mode
    V = { "V-LINE", "4" },            -- Visual by line
    Vs = { "V-LINE", "4" },           -- Visual by line using |v_CTRL-O| in Select mode
    ["\22"] = { "V-BLOCK", "4" },     -- Visual blockwise
    ["\22s"] = { "V-BLOCK", "4" },    -- Visual blockwise using |v_CTRL-O| in Select mode
    s = { "SELECT", "5" },            -- Select by character
    S = { "S-LINE", "5" },            -- Select by line
    ["\19"] = { "S-BLOCK", "5" },     -- Select blockwise
    i = { "INSERT", "2" },            -- Insert
    ic = { "INSERT", "2" },           -- Insert mode completion |compl-generic|
    ix = { "INSERT", "2" },           -- Insert mode |i_CTRL-X| completion
    R = { "REPLACE", "6" },           -- Replace |R|
    Rc = { "REPLACE", "6" },          -- Replace mode completion |compl-generic|
    Rx = { "REPLACE", "6" },          -- Replace mode |i_CTRL-X| completion
    Rv = { "V-REPLACE", "6" },        -- Virtual Replace |gR|
    Rvc = { "V-REPLACE", "6" },       -- Virtual Replace mode completion |compl-generic|
    Rvx = { "V-REPLACE", "6" },       -- Virtual Replace mode |i_CTRL-X| completion
    c = { "COMMAND", "7" },           -- Command-line editing
    cr = { "COMMAND", "7" },          -- Command-line editing overstrike mode |c_<Insert>|
    cv = { "EX", "7" },               -- Vim Ex mode |gQ|
    cvr = { "EX", "7" },              -- Vim Ex mode while in overstrike mode |c_<Insert>|
    r = { "PROMPT", "3" },            -- Hit-enter prompt
    rm = { "MORE", "3" },             -- The -- more -- prompt
    ["r?"] = { "CONFIRM", "3" },      -- A |:confirm| query of some sort
    ["!"] = { "SHELL", "4" },         -- Shell or external command is executing
    t = { "TERMINAL", "5" },          -- Terminal mode: keys go to the job
}

local ITEM_SEP = "|"

function Statusline.active(branch)
    local mode = vim.fn.mode()
    local mode_name = " " .. (mode_map[mode][1] or mode) .. ITEM_SEP
    local hlUser = "%" .. (mode_map[mode][2] or "") .. "*"
    if mode == "t" then
        return hlUser .. mode_name .. "%*"
    else
        return hlUser .. mode_name .. "%*" .. branch .. " %F %6*%m%* %=%Y" .. ITEM_SEP .. "%P %l:%c "
    end
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
    group = group,
    desc = "Activate statusline on focus",
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "" then
            -- If not normal buffer exit early
            return
        end
        local branch = vim.trim(vim.fn.system("git-wrapper stline"))
        -- Enter 5-digit hex code in Insert mode: <C-r>=nr2char(0xf062c)
        -- For regular 4-code ie. e0a0, in Insert mode: <C-v> u e0a0
        if branch ~= "" then
            local git_folder = " " ..
                vim.trim(vim.fn.system("git-wrapper rev-parse --absolute-git-dir | sed \"s|^$HOME|~|\""))
            branch = git_folder .. ITEM_SEP .. "󰘬 " .. branch .. ITEM_SEP

            local name = vim.api.nvim_buf_get_name(0)
            if name ~= "" then
                local is_untracked = vim.fn.system("git-wrapper ls-files --error-unmatch " ..
                    vim.fn.expand("%:p") .. " 2>/dev/null") == ""
                if is_untracked then
                    branch = branch .. "%#CurSearch#󰡯 "
                end
            end
        end
        vim.opt_local.statusline = '%!v:lua.Statusline.active("' .. branch .. '")'
    end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = group,
    desc = "Deactivate statusline when unfocused",
    callback = function()
        vim.opt_local.statusline = "%t"
    end,
})
