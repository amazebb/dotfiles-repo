Statusline = {}

vim.api.nvim_set_hl(0, 'User2', { fg = '#FFFF00' })
vim.api.nvim_set_hl(0, 'User3', { fg = '#8B0000' })
vim.api.nvim_set_hl(0, 'User4', { fg = '#aaff00' })
vim.api.nvim_set_hl(0, 'User5', { fg = '#0099ff' })
vim.api.nvim_set_hl(0, 'User6', { fg = '#fB4500' })
vim.api.nvim_set_hl(0, 'User7', { fg = '#00FF00' })

local LHS_ITEM_SEP = " | "
local RHS_ITEM_SEP = " | "
local git_status = ""
local lsp_status = false

local function toggle_git_folder()
    vim.g.enable_git_folder = not vim.g.enable_git_folder
end

local function toggle_symbols()
    vim.g.statusline_symbols = not vim.g.statusline_symbols
end

local function update_git_status()
    git_status = vim.trim(vim.fn.system("git-wrapper stline"))
    -- Enter 5-digit hex code in Insert mode: <C-r>=nr2char(0xf062c)
    -- For regular 4-code ie. e0a0, in Insert mode: <C-v> u e0a0
    if git_status ~= "" then
        if vim.g.enable_git_folder then
            local git_folder = (vim.g.statusline_symbols and " " or "") ..
                vim.trim(vim.fn.system("git-wrapper rev-parse --absolute-git-dir | sed \"s|^$HOME|~|\""))
            git_status = git_folder ..
                LHS_ITEM_SEP .. (vim.g.statusline_symbols and "󰘬 " or "") .. git_status .. LHS_ITEM_SEP
        else
            git_status = (vim.g.statusline_symbols and "󰘬 " or "") .. git_status .. LHS_ITEM_SEP
        end

        local name = vim.api.nvim_buf_get_name(0)
        if name ~= "" then
            local is_untracked = vim.fn.system("git-wrapper ls-files --error-unmatch " ..
                vim.fn.expand("%:p") .. " 2>/dev/null") == ""
            if is_untracked then
                git_status = git_status .. "%#CurSearch#󰡯 "
            end
        end
    end
end

local function update_lsp_status()
    lsp_status = vim.lsp.get_clients({ bufnr = 0 }) ~= nil
end

function Statusline.set_statusline()
    local mode = vim.fn.mode():gsub("%c", "")
    local mode_name = ({ n = "NORMAL", i = "INSERT", v = "VISUAL", V = "VISUAL",
            s = "SELECT", S = "SELECT", R = "REPLACE", c = "COMMAND", r = "PROMPT", t = "TERM", ["!"] = "SHELL" })
        [mode:sub(1, 1)] or mode
    local colors = {
        NORMAL = "1",
        INSERT = "2",
        VISUAL = "4",
        SELECT = "5",
        REPLACE = "6",
        COMMAND = "7",
        TERM = "5",
        PROMPT = "5",
        SHELL = "5"
    }
    local hlMode = "%" .. (colors[mode_name] or "") .. "*"
    if mode == "t" then
        return hlMode .. mode_name .. "%*"
    else
        return hlMode .. mode_name .. "%*"
            .. LHS_ITEM_SEP ..
            git_status ..
            "%F %6*%m%* %=%Y " ..
            (lsp_status and (vim.g.statusline_symbols and "󱐋" or "[LSP]") or "") .. RHS_ITEM_SEP .. "%P %l:%c "
    end
end

local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
    -- TODO Consider some of these, but seems to be working ok..
    -- "FocusGained", "DirChanged", "TermClose"
    group = group,
    desc = "Activate statusline on focus",
    callback = function(ev)
        if vim.bo[ev.buf].buftype == "" then
            update_git_status()
            update_lsp_status()
            vim.opt_local.statusline = '%!v:lua.Statusline.set_statusline()'
        end
    end
})

vim.api.nvim_create_user_command("StatusLineToggleSymbols", function()
    toggle_symbols()
    update_git_status()
    update_lsp_status()
end, { desc = "Toggle the statusline symbols" })

vim.api.nvim_create_user_command("StatusLineToggleGitFolder", function()
    toggle_git_folder()
    update_git_status()
end, { desc = "Toggle the statusline git folder" })
